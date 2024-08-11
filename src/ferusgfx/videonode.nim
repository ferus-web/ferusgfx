import std/[options, logging]
import ferusgfx/drawable
import ffmpeg

type
  CodecInfo* = (ptr AVCodecParameters, ptr AVCodec, int)
  
  VideoOpenError* = object of ValueError
  InvalidStreamError* = object of ValueError
  MissingCodecInfo* = object of ValueError
  ContextAllocationError* = object of ValueError
  AudioDeviceError* = object of ValueError

  VideoNode* = ref object of Drawable
    avFormatContext*: ptr AVFormatContext
    
    file: string
    codecCtx*, audioCtx*: AVCodecContext
    videoParams*, audioParams*: AVCodecParameters
    codec*, audioCodec*: AVCodec
    frame*, audioFrame*: ptr AVFrame
    packet*, audioPacket*: ptr AVPacket
    videoInfo*, audioInfo*: CodecInfo

proc paramAndCodec(ctx: ptr AVFormatContext, videoCodec, audioCodec: var CodecInfo): (int, float) =
  var
    streams = cast[ptr UncheckedArray[ptr AVStream]](ctx[].streams)
    foundVideo = false
    foundAudio = false

  for i in 0 ..< ctx[].nb_streams:
    let local = streams[i][].codecpar
    if local[].codec_type == AVMEDIA_TYPE_VIDEO:
      let rat = streams[i].avg_frame_rate
      info "Video average framerate: " & $rat
      videoCodec[2] = int i
      result[0] = int i
      result[1] = 1f / (rat.num.float / rat.den.float)

      videoCodec[0] = local
      videoCodec[1] = avcodec_find_decoder(local[].codec_id)
      foundVideo = true
    elif local[].codec_type == AVMEDIA_TYPE_AUDIO:
      audioCodec[2] = int i
      audioCodec[0] = local

      audioCodec[1] = avcodec_find_decoder(local[].codec_id)
      foundAudio = true

    if foundAudio and foundVideo: break

proc allocContext(vidCtx, audCtx: ptr AVCodecContext, vidinfo, audinfo: CodecInfo) =
  moveMem(vidctx, avcodec_alloc_context3(vidinfo[1]), sizeof(AVCodecContext))
  moveMem(audctx, avcodec_alloc_context3(audinfo[1]), sizeof(AVCodecContext))
  #vidctx[] = avcodec_alloc_context3(vidinfo[1])
  #audctx[] = avcodec_alloc_context3(audinfo[1])
  
  info "video: allocating video context"
  if (let code = avcodec_parameters_to_context(vidCtx, vidinfo[0]); code < 0):
    raise newException(ContextAllocationError, "avcodec_parameters_to_context() returned " & $code)

  if (let code = avcodec_open2(vidctx, vidinfo[1], nil); code < 0):
    raise newException(MissingCodecInfo, "Cannot open video codec as avcodec_open2() returned " & $code)
  
  info "video: allocating audio context"
  if (let code = avcodec_parameters_to_context(audCtx, audinfo[0]); code < 0):
    raise newException(ContextAllocationError, "avcodec_parameters_to_context() returned " & $code)

  if (let code = avcodec_open2(audctx, audinfo[1], nil); code < 0):
    raise newException(MissingCodecInfo, "Cannot open audio codec as avcodec_open2() returned " & $code)

proc newVideoNode*(file: string): VideoNode =
  var node = VideoNode(
    file: file
  )
  node.avFormatContext = avformat_alloc_context()

  if avformat_open_input(addr node.avFormatContext, file, nil, nil) < 0:
    raise newException(VideoOpenError, "Cannot open input stream for file: " & file)
  
  if avformat_find_stream_info(node.avFormatContext, nil) < 0:
    raise newException(InvalidStreamError, "Failed to find stream information for file: " & file)
  
  node.videoInfo = (addr node.videoParams, addr node.codec, -1)
  node.audioInfo = (addr node.audioParams, addr node.audioCodec, -1)
  let (videoIndex, targetFps) = node.avFormatContext.paramAndCodec(node.videoInfo, node.audioInfo)

  if videoIndex == -1:
    raise newException(InvalidStreamError, "Couldn't find video stream for file: " & file)

  info "Video stream resolution: " & $node.videoInfo[0][].width & 'x' & $node.videoInfo[0][].height
  info "Video target FPS: " & $targetFps

  if node.videoInfo[1] == nil:
    raise newException(MissingCodecInfo, "Cannot find codec for file: " & file)

  allocContext(node.codecCtx.addr, node.audioCtx.addr, node.videoInfo, node.audioInfo)
  let parser = av_parser_init(cint node.audioInfo[1].id)

  info "Video pixel format: " & $node.codecCtx.pix_fmt
  info "Video codec ID: " & $node.codecCtx.codec_id

  node.frame = av_frame_alloc()
  node.audioFrame = av_frame_alloc()

  node.packet = av_packet_alloc()
  node.audioPacket = av_packet_alloc()

  node

export av_register_all
