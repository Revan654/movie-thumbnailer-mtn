
/*
set first to 1 when calling this for the first time of a file
return >0 if can read packet(s) & decode a frame, *pPts is set to packet's pts
return  0 if end of file
return <0 if error
*/
int read_and_decode(AVFormatContext *pFormatCtx, int video_index,
    AVCodecContext *pCodecCtx, AVFrame *pFrame, int64_t *pPts, int key_only, int first)
{
    //double pts = -99999;
    AVPacket packet;
    AVStream *pStream = pFormatCtx->streams[video_index];
    int decoded_frame = 0;
    static int run = 0; // # of times read_and_decode has been called for a file
    static double avg_decoded_frame = 0; // average # of decoded frame
    static int skip_non_key = 0;
    int decoded;

    if (first) {
        // reset stats
        run = 0;
        avg_decoded_frame = 0;
        skip_non_key = 0;
    }

    int got_picture;
    int pkt_without_pic = 0; // # of video packet read without getting a picture
    //for (got_picture = 0; 0 == got_picture; av_free_packet(&packet)) {
    // keep decoding until we get a key frame
    for (got_picture = 0; 0 == got_picture 
        //|| (1 == key_only && !(1 == pFrame->key_frame && FF_I_TYPE == pFrame->pict_type)); // same as version 0.61
        || (1 == key_only && !(1 == pFrame->key_frame || AV_PICTURE_TYPE_I  == pFrame->pict_type)); // same as version 2.42
        //|| (1 == key_only && 1 != pFrame->key_frame); // is there a reason why not use this? t_warhawk_review_gt_h264.mov (svq3) seems to set only pict_type
        av_packet_unref(&packet)) {

        if (0 != av_read_frame(pFormatCtx, &packet)) {
            if (pFormatCtx->pb->error != 0) { // from ffplay - not documented
                return -1;
            }
            return 0;
        }

        // Is this a packet from the video stream?
        if (packet.stream_index != video_index) {
            continue;
        }
        
        // skip all non-key packet? would this work? // FIXME
        // this seems to slow down nike files. why?
        // so we'll use it only when a key frame is difficult to find.
        // hope this wont break anything. :)
        // this seems to help a lot for files with vorbis audio
        if (1 == skip_non_key && 1 == key_only && !(packet.flags & AV_PKT_FLAG_KEY)) {
            continue;
        }
        
        dump_packet(&packet, pStream);
        //dump_codec_context(pCodecCtx);

        // Save global pts to be stored in pFrame in first call
        av_log(NULL, AV_LOG_VERBOSE, "*saving gb_video_pkt_pts: %"PRId64"\n", packet.pts);
        gb_video_pkt_pts = packet.pts;

        // Decode video frame
        decoded = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, &packet);
        if(decoded < 0)
        {
            av_log(NULL, AV_LOG_ERROR, "coul'd not decode frame (ret=%d)\n", decoded);
            return -1;
        }
        // error is ignored. perhaps packets read are not enough.
        av_log(NULL, AV_LOG_VERBOSE, "*avcodec_decode_video2: got_picture: %d, key_frame: %d, pict_type: %d, decoded: %d Bytes\n", got_picture, pFrame->key_frame, pFrame->pict_type, decoded);

        // FIXME: with some .dat files, got_picture is never set, why??

        if (0 == got_picture) {
            pkt_without_pic++;
            if (0 == pkt_without_pic%50) {
                av_log(NULL, LOG_INFO, "  no picture in %d packets\n", pkt_without_pic);
            }
            if (1000 == pkt_without_pic) { // is 1000 enough? // FIXME
                av_log(NULL, AV_LOG_ERROR, "  * avcodec_decode_video2 couldn't decode picture\n");
                av_packet_unref(&packet);
                return -1;
            }
        } else {
            pkt_without_pic = 0;
            decoded_frame++;
            // some codecs, e.g avisyth, dont seem to set key_frame
            if (1 == key_only && 0 == decoded_frame%200) {
                av_log(NULL, LOG_INFO, "  a key frame is not found in %d frames\n", decoded_frame);
            }
            if (1 == key_only && 400 == decoded_frame) {
                // is there a way to know when a frame has no missing pieces 
                // even though it's not a key frame?? // FIXME
                av_log(NULL, LOG_INFO, "  * using a non-key frame; file problem? ffmpeg's codec problem?\n");
                break;
            }
        }

        // WTH?? why copy pts from dts?
        /*
        if(AV_NOPTS_VALUE == packet.dts 
            && NULL != pFrame->opaque 
            && AV_NOPTS_VALUE != *(uint64_t *) pFrame->opaque) {
            pts = *(uint64_t *)pFrame->opaque;
        } else if(packet.dts != AV_NOPTS_VALUE) {
            pts = packet.dts;
        } else {
            pts = 0;
        }
        pts *= av_q2d(pStream->time_base);
        //av_log(NULL, AV_LOG_VERBOSE, "*after avcodec_decode_video pts: %.2f\n", pts);
        */
    } //end of for()
    av_packet_unref(&packet);

    // stats & enable skipping of non key packets
    run++;
    avg_decoded_frame = (avg_decoded_frame*(run-1) + decoded_frame) / run;
    //av_log(NULL, LOG_INFO, "  decoded frames: %d, avg. decoded frames: %.2f, pict_type: %d\n", 
    //    decoded_frame, avg_decoded_frame, pFrame->pict_type); // DEBUG
    if (0 == skip_non_key && run >= 3 && avg_decoded_frame > 30) {
        skip_non_key = 1;
        av_log(NULL, LOG_INFO, "  skipping non key packets for this file\n");
    }

    av_log(NULL, AV_LOG_VERBOSE, "*****got picture, repeat_pict: %d%s, key_frame: %d, pict_type: %d\n", pFrame->repeat_pict,
        (pFrame->repeat_pict > 0) ? "**r**" : "", pFrame->key_frame, pFrame->pict_type);
    if(NULL != pFrame->opaque && (uint64_t)AV_NOPTS_VALUE != *(uint64_t *) pFrame->opaque) {
        //av_log(NULL, AV_LOG_VERBOSE, "*pts: %.2f, value in opaque: %"PRId64"\n", pts, *(uint64_t *) pFrame->opaque);
        av_log(NULL, AV_LOG_VERBOSE, "*value in opaque: %"PRId64"\n", *(uint64_t *) pFrame->opaque);
    }
    dump_stream(pStream);
    dump_codec_context(pCodecCtx);

    //    *pPts = packet.pts;  -> unreferenced after av_packet_unref(&packet)!
    *pPts = gb_video_pkt_pts;
    return 1;
}

