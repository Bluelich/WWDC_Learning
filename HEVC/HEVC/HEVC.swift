//
//  HEVC.swift
//  HEVC
//
//  Created by zhouqiang on 17/10/2017.
//  Copyright © 2017 Bluelich. All rights reserved.
//

import UIKit
import Photos
import VideoToolbox
import AVFoundation
import MobileCoreServices
import ImageIO.CGImageProperties
import CoreVideo

protocol HEVC_PIC {}
protocol HEVC_PIC_HEIC:HEVC_PIC {}
protocol HEVC_PIC_AVCI:HEVC_PIC {}
protocol HEVC_PIC_HEIF:HEVC_PIC {}

protocol HEVC_Access   {}
protocol HEVC_Playback {}
protocol HEVC_Capture  {}
protocol HEVC_Export   {}
protocol HEVC_Movie_Capture : HEVC_Capture {}
protocol HEVC_Live_Photo_Movie_Capture : HEVC_Movie_Capture {}
protocol HEVC_Movie_AVAssetWriter_Capture : HEVC_Movie_Capture {}

protocol HEVC_Support {}

#if arch(arm64)//arm arm64 i386 x86_64
#endif
#if swift(>=3.1)
#endif

class HEVC: NSObject {
    /*
     HEVC movies are up to 40% smaller than H.264
     HEVC playback is supported everywhere on iOS 11 and macOS High Sierra
     Opt in to create HEVC content using capture and export APIs
     HEIC files are twice as small as JPEGs
     HEIF decode is supported everywhere on iOS 11 and macOS High Sierra
     Capture HEIC files using the new AVCapturePhoto interface
     */
    let manager = PHImageManager.default()
    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: NSError?) {
        if #available(iOS 10.0, *) {
            if #available(iOS 11.0, *) {}else{
                guard let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) else {
                    return
                }
                print("image.size:%@",NSStringFromCGSize((UIImage(data: dataImage)?.size)!));
            }
        }
    }
    func Common_PhotoKit_Workflows() {
        /*
         Display :
         PHImageManager for UIImage, AVPlayerItem, or PHLivePhoto
         No code changes needed
         */
        /*
         Backup:
         PHAssetResourceManager provides resources in native format
         */
        func other_without_support() {
            func image(asset:PHAsset,options:PHImageRequestOptions?) {
                // for images, check the UTI and convert if needed:
                manager.requestImageData(for: asset, options: options) { (imageData:Data?, dataUTI:String?, orientation:UIImageOrientation, info:[AnyHashable:Any]?) in
                    guard let dataUTI = dataUTI else {
                        return
                    }
                    if !UTTypeConformsTo(dataUTI as CFString, kUTTypeJPEG) {
                        // convert the data to a JPEG representation...
                    }
                }
            }
            func video(asset:PHAsset,options:PHVideoRequestOptions?) {
                // for videos use export preset to specify the format
                manager.requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality, resultHandler: { (exportSession:AVAssetExportSession?, info:[AnyHashable:Any]?) in
                    
                })
            }
        }
    }
}
extension HEVC : HEVC_Access {
    func HEVC_Assets_From_Photos(asset:PHAsset) {
        PhotoKit_will_deliver_HEVC_assets_for_playback(asset: asset)
        PhotoKit_will_deliver_HEVC_assets(asset: asset)
    }
    func PhotoKit_will_deliver_HEVC_assets_for_playback(asset:PHAsset) {
        // PHImageManager
        manager.requestPlayerItem(forVideo: asset, options: nil) { (playerItem, dictionary) in
            // use AVPlayerItem
        }
        manager.requestLivePhoto(for: asset, targetSize: CGSize.zero, contentMode: .default, options: nil) { (livePhoto, dictionary) in
            // use PHLivePhoto
        }
    }
    func PhotoKit_will_deliver_HEVC_assets(asset:PHAsset) {
        let validPresets:[String] = AVAssetExportSession.exportPresets(compatibleWith: AVAsset());
        manager.requestExportSession(forVideo: asset, options: nil, exportPreset: validPresets.first!) { (exportSession, dictionary) in
            // use AVAssetExportSession
        }
        manager.requestAVAsset(forVideo: asset, options: nil) { (asset, audioMix, dictionary) in
            // use AVAsset
        }
    }
    func Access_HEVC_movie_file_data() {
        let assetResource = PHAssetResource()
        let resourceManager = PHAssetResourceManager.default()
        resourceManager.requestData(for: assetResource, options: nil, dataReceivedHandler: { (data) in
            // use Data
        }) { (error) in
            // handle Error
        }
    }
}
extension HEVC : HEVC_Playback {
    func Native_Playback_Support() {
        /*
         Supported in modern media frameworks
         Streaming, play-while-download, and local files are supported
         MPEG-4, QuickTime file format container support
         No API opt-in required
         */
    }
    func HEVC_Decode_Support()  {
        /*
         8-bit  Hardware Decode : iOS(A9+) macOS(6+ Intel Core processor)
         10-bit Hardware Decode : iOS(A9+) macOS(7+ Intel Core processor)
         8-bit  Software Decode : iOS(all) macOS(all)
         10-bit Software Decode : iOS(all) macOS(all)
         */
    }
    func play() {
        let player = AVPlayer(url: URL(fileURLWithPath: "MyAwesomeMovie.mov"));
        player.play()
    }
    func Decode_Capability(assetTrack:AVAssetTrack) {
       /*
         Useful for non-realtime operations
         Can be limited by hardware support
         */
        if assetTrack.isDecodable {
            print("Decodable")
        }
    }
    func Playback_Capability(assetTrack:AVAssetTrack) {
        /*
         Not all content can be played back in realtime
         Differing capabilities on device
         */
        if assetTrack.isPlayable {
            print("Playable")
        }
    }
    func Hardware_Decode_Availability() {
        /*
         Longest battery life
         Best decode performance
         */
        if VTIsHardwareDecodeSupported(kCMVideoCodecType_HEVC) {
            print("HardwareDecodeSupported")
        }
    }
}
extension HEVC : HEVC_Capture {
    /*
     Capture HEVC movies with AVFoundation
     MPEG-4, QuickTime file format container support
     */
    func HEVC_Capture_Support() {
        /*
         8-Bit Hardware Encode: iOS(A10+)
         */
    }
}
extension HEVC : HEVC_Movie_Capture,AVCaptureFileOutputRecordingDelegate {
    // AVCaptureDevice -> AVCaptureDeviceInput -> AVCaptureConnection -> AVCaptureSession -> AVCaptureMovieFileOutput -> Movie
    func Capturing_Movies_with_HEVC() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: nil, position: .back), let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        let movieFileOutput = AVCaptureMovieFileOutput()
        
        let session = AVCaptureSession()
        session.sessionPreset = .hd4K3840x2160
        session.addInput(input)
        session.addOutput(movieFileOutput)
        session.startRunning()
        
        let moviePath = documentPath.appendingPathComponent("test").appendingPathExtension("mov")
        movieFileOutput.startRecording(to: moviePath, recordingDelegate: self)
        
        guard let connection = movieFileOutput.connection(with: .video) else {
            return
        }
        var videoCodecType:AVVideoCodecType = .h264
        if movieFileOutput.availableVideoCodecTypes.contains(.hevc) {
            videoCodecType = .hevc
        }else{
            videoCodecType = .h264
        }
        let outputSetings = [AVVideoCodecKey: videoCodecType,AVVideoQualityKey:NSNumber(value: 0.6)] as [String : Any];
        movieFileOutput.setOutputSettings(outputSetings, for: connection)
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("StartRecording")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("FinishRecording")
    }
}

extension HEVC : HEVC_Live_Photo_Movie_Capture,AVCapturePhotoCaptureDelegate {
    // Live Photo 增强: 视频稳定性, 音乐回放, 30 FPS
    // AVCaptureDevice -> AVCaptureDeviceInput ->  AVCaptureSession -> AVCapturePhotoOutput -> Photo
    func Capturing_Live_Photo_Movies_with_HEVC() {
        let photoSettings = AVCapturePhotoSettings()
        let fileURL = documentPath.appendingPathComponent("test").appendingPathExtension(".pic")
        photoSettings.livePhotoMovieFileURL = fileURL
        let photoOutput = AVCapturePhotoOutput()
        if photoOutput.availableLivePhotoVideoCodecTypes.contains(.hevc) {
            photoSettings.livePhotoVideoCodecType = .hevc
        }
        let pixelFormatType = NSNumber(value: kCVPixelFormatType_32BGRA)
        if photoSettings.__availablePreviewPhotoPixelFormatTypes.contains(pixelFormatType) {
            //pixelFormatType  = ...
        }
        let previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey    : pixelFormatType,
                                  kCVPixelBufferWidthKey              : 320,
                                  kCVPixelBufferHeightKey             : 480,
                                  kCVPixelFormatOpenGLESCompatibility : kCFBooleanTrue]
        photoSettings.previewPhotoFormat = previewPhotoFormat as [String:Any]
        photoSettings.embeddedThumbnailPhotoFormat = [AVVideoCodecKey :AVVideoCodecType.hevc,
                                                      AVVideoWidthKey :320,
                                                      AVVideoHeightKey:320]
        /*!
         Valid metadata keys are found in <ImageIO/CGImageProperties.h>. AVCapturePhotoOutput inserts a base set of metadata into each photo it captures, such as kCGImagePropertyOrientation, kCGImagePropertyExifDictionary, and kCGImagePropertyMakerAppleDictionary. You may specify metadata keys and values that should be written to each photo in the capture request. If you've specified metadata that also appears in AVCapturePhotoOutput's base set, your value replaces the base value. An NSInvalidArgumentException is thrown if you specify keys other than those found in <ImageIO/CGImageProperties.h>.
         */
        /*
         1  =  top    left(default)
         2  =  top    right
         3  =  bottom right
         4  =  bottom left
         5  =  left   top
         6  =  right  top
         7  =  right  bottom
         8  =  left   bottom
         */
        let gps  = [kCGImagePropertyGPSLatitude    : "39.90960456049752",
                    kCGImagePropertyGPSLatitudeRef : "N",
                    kCGImagePropertyGPSLongitude   : "116.3972282409668",
                    kCGImagePropertyGPSLongitudeRef: "E",
                    kCGImagePropertyGPSTimeStamp   : Date().string()]
        let exif = [kCGImagePropertyExifFlash           : kCFBooleanTrue,
                    kCGImagePropertyGPSDictionary       : gps,
                    kCGImagePropertyExifCameraOwnerName :"bluelich",
                    kCGImagePropertyExifDateTimeOriginal:Date()] as [CFString : Any]
        let metadata = [kCGImagePropertyOrientation             : NSNumber(value: 1) as CFNumber,
                        kCGImagePropertyExifDictionary          : exif,
                        kCGImagePropertyMakerAppleDictionary    : ""] as [CFString : Any]
        photoSettings.metadata = metadata as [String : Any]
        photoOutput.capturePhoto(with: photoSettings, delegate: self);
    }
    /*
     AVCapturePhotoOutput Usage
     -> AVCapturePhotoSettings (e.g. flashMode = .auto, preview = 1440x1440)
     -> AVCapturePhotoCaptureDelegate
     */
    func AVCapturePhotoCaptureDelegate() {
       /*
         willBeginCaptureFor
         willCapturePhotoFor
         didCapturePhotoFor
         didFinishRawCaptureFor
         didFinishProcessingPhoto
         didFinishProcessingLivePhotoMovie
         didFinishCaptureFor
         */
    }
    func CMSampleBuffer_vs_HEIF(photo:AVCapturePhoto) {
        /*
         Sample buffer contains media data
         HEIF contains a file structure
         HEVC video is not the same as HEIF HEVC
         Faster CMSampleBuffer replacement
         100% immutable
         Backed by containerized data
         */
        /*
         open var timestamp: CMTime { get }
         open var isRawPhoto: Bool { get }
         open var pixelBuffer: CVPixelBuffer? { get }
         open var previewPixelBuffer: CVPixelBuffer? { get }
         open var embeddedThumbnailPhotoFormat: [String : Any]? { get }
         open var metadata: [String : Any] { get } open var depthData: AVDepthData? { get }
         open var resolvedSettings: AVCaptureResolvedPhotoSettings { get }
         open var photoCount: Int { get }
         open var bracketSettings: AVCaptureBracketedStillImageSettings? { get }
         open var sequenceCount: Int { get }
         open var lensStabilizationStatus: AVCaptureDevice.LensStabilizationStatus { get }
         open func fileDataRepresentation() -> Data?
         open func cgImageRepresentation() -> Unmanaged<CGImage>?
         open func previewCGImageRepresentation() -> Unmanaged<CGImage>?
         */
    }
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings){}
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings){}
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings){}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?){ guard let data = photo.fileDataRepresentation() else {return}; print(data) }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingRawPhoto rawSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings){}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?){}
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?){}
}

extension HEVC : HEVC_Movie_AVAssetWriter_Capture {
    // AVCaptureDevice -> AVCaptureDeviceInput ->  AVCaptureSession -> AVCaptureVideoDataOutput -> sbuf -> AVAssetWriter -> Movie
    func Capturing_HEVC_Movies_with_AVAssetWriter() {
        /*
         Configure AVAssetWriterInput with output settings
         Video data output can recommend settings
         */
        let vdo = AVCaptureVideoDataOutput()
        vdo.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
        vdo.recommendedVideoSettings(forVideoCodecType: .hevc, assetWriterOutputFileType: .mov)
    }
}

extension HEVC : HEVC_Export {
    /*
     Transcode to HEVC with AVFoundation and VideoToolbox
     MPEG-4, QuickTime file format container support
     API opt-in required
     */
    func HEVC_Encode_Support() {
        /*
         8-bit  Hardware Encode : iOS(A10+) macOS(6+ Intel Core processor)
         10-bit Software Encode :   N/A     macOS(all)
         */
    }
    func Transcode_with_AVAssetExportSession() {
        //Movie -> AVAssetExportSession -> Movie
    }
    func Export_Session() {
        /*
         No change in behavior for existing presets
         Convert from H.264 to HEVC with new presets
         Produce smaller AVAssets with same quality
         */
        let _ = AVAssetExportPresetHEVC1920x1080
        let _ = AVAssetExportPresetHEVC3840x2160
        let _ = AVAssetExportPresetHEVCHighestQuality
    }
    func Compression_with_AVAssetWriter() {
        //sbuf -> AVAssetWriter -> Movie
        var preset:AVOutputSettingsPreset = .hevc1920x1080
        let availableOutputSettingsPresets = AVOutputSettingsAssistant.availableOutputSettingsPresets()
        if availableOutputSettingsPresets.contains(.hevc3840x2160) {
            preset = .hevc3840x2160
        }
        let assistant = AVOutputSettingsAssistant(preset: preset)
        let settings = assistant?.videoSettings //也可以直接设置,不用预置参数
        print(settings as Any)
    }
    func Valid_Output_Settings(encoderSpecification:CFDictionary?, encoderID: inout CFString?, properties: inout CFDictionary?) {
        //Encoder ID is a unique identifier for an encoder
        //Properties and encoder ID can be used in output settings
        let error = VTCopySupportedPropertyDictionaryForEncoder(3840, 2160, kCMVideoCodecType_HEVC, encoderSpecification, &encoderID, &properties)
        if error == kVTCouldNotFindVideoEncoderErr {
            // no HEVC encoder
        }
    }
    func Compression_Session(session: inout VTCompressionSession?) {
        //sbuf -> VTCompressionSession -> hvc1
        // available keys -> VTCompressionProperties.h
        var encoderSpecification:[CFString:Any] = [:]
        #if os(OSX)
            // Use hardware when available on macOS
            //Realtime encode, fail if no hardware exists on macOS
            encoderSpecification[kVTVideoEncoderSpecification_EnableHardwareAcceleratedVideoEncoder] = true
        #endif
        //CoreVideo pixel buffer format
        //kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange // 10-bit 4:2:0
        
        //10 bit depth
        //Check for support with function VTSessionCopySupportedPropertyDictionary(...)
        encoderSpecification[kVTCompressionPropertyKey_ProfileLevel] = kVTProfileLevel_HEVC_Main10_AutoLevel
        //VTCompressionSessionEncodeFrameWithOutputHandler
        func h264(){
            let status = VTCompressionSessionCreate(kCFAllocatorDefault, 3840, 2160, kCMVideoCodecType_H264, encoderSpecification as CFDictionary, nil, nil, nil, nil, &session)
            if status == kVTCouldNotFindVideoEncoderErr {
                // no H.264 encoder
            }
        }
        func hevc() {
            let status = VTCompressionSessionCreate(kCFAllocatorDefault, 3840, 2160, kCMVideoCodecType_HEVC, encoderSpecification as CFDictionary, nil, nil, nil, nil, &session)
            if status == kVTCouldNotFindVideoEncoderErr {
                // no HEVC encoder
            }
        }
    }
}
//HEIF
extension HEVC : HEVC_PIC_HEIC, HEVC_PIC_AVCI, HEVC_PIC_HEIF {
    func Hierarchical_Frame_Encoding() {}
    func What_the_HEIC() {
        /*
         [Payload]       [Extension]   [UTI]
         HEVC Image      .HEIC         "public.heic"
         H.264 Image     .AVCI         "public.avci"
         Anything Else   .HEIF         "public.heif"
         */
        //Supported HEIF Flavors (Writing)
    }
    func LowLevel_Access_to_HEIF() {
        func ImageIO() {
            func read_from_file() {
                //jpeg
                var inputURL = URL(fileURLWithPath: "/tmp/image.jpg")
                //heic
                inputURL = URL(fileURLWithPath: "/tmp/image.heic")
                guard let source = CGImageSourceCreateWithURL(inputURL as CFURL, nil) else {
                    return
                }
                let imageProperties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)//metadata
                let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
                let options = [kCGImageSourceCreateThumbnailFromImageIfAbsent:true,
                               kCGImageSourceThumbnailMaxPixelSize:320] as CFDictionary
                let thumb = CGImageSourceCreateThumbnailAtIndex(source, 0, options)
                print(imageProperties as Any,image as Any,thumb as Any)
            }
            func write_to_file(image:CGImage) {
                //JPEG
                var image_extension = ".jpg"
                var imageType:AVFileType = .jpg
                //HEIC
                image_extension = ".heic"
                imageType = .heic
                let url = URL(fileURLWithPath: "/tmp/output" + image_extension) as CFURL
                guard let imageDestination = CGImageDestinationCreateWithURL(url, imageType as CFString, 1, nil) else {
                    fatalError("unable to create CGImageDestination")
                }
                CGImageDestinationAddImage(imageDestination, image, nil)
                CGImageDestinationFinalize(imageDestination)
            }
            func Depth_Support() {
                /*
                 HEIC : Auxiliary image (monochrome HEVC) with XMP metadata
                 JPEG : MPO       image (jpeg encoded)    with XMP metadata
                 */
            }
        }
    }
    func HighLevel_Access_to_HEIF() {
        func PhotoKit() {
            /*
             Applying adjustments : 1.Photos  2.Videos 3.Live Photos
             Common workflows     : 1.Display 2.Backup 3.Share
             */
            func Applying_adjustments(){
                //PHAsset -> PHContentEditingInput -> PHContentEditingOutput -> renderedContentURL -> Image
                /*
                 PHContentEditingOutput
                 1.Image rendered as JPEG
                 2.Image Exif orientation of 1 (no rotation)
                 */
                func Editing_a_HEIF_photo__save_as_JPEG(){
                    func applyPhotoFilter(_ filterName: String, input: PHContentEditingInput, output: PHContentEditingOutput, completion: () -> ()) {
                        guard let inputImage = CIImage(contentsOf: input.fullSizeImageURL!) else {
                            fatalError("can't load input image")
                            
                        }
                        let outputImage = inputImage.oriented(CGImagePropertyOrientation(rawValue: UInt32(input.fullSizeImageOrientation))!).applyingFilter(filterName)
                        // Write the edited image as a JPEG.
                        do {
                            //also can use an existed context
                            let context = CIContext()
                            try context.writeJPEGRepresentation(of: outputImage,to: output.renderedContentURL, colorSpace: inputImage.colorSpace!, options: [:])
                        } catch let error {
                            print("can't apply filter to image: \(error)")
                            return
                        }
                        completion()
                    }
                }
                /*
                 PHContentEditingOutput : Video rendered as H.264
                 */
                func Editing_an_HEVC_video__save_as_H264(){
                    func applyVideoFilter(_ filterName: String, input: PHContentEditingInput, output: PHContentEditingOutput, completionHandler: @escaping () -> Void) {
                        guard let avAsset = input.audiovisualAsset else {
                            fatalError("can't get AV asset")
                        }
                        let composition = AVVideoComposition(asset: avAsset) { (request:AVAsynchronousCIImageFilteringRequest) in
                            let img = request.sourceImage.applyingFilter(filterName)
                            request.finish(with: img, context: nil)
                        }
                        // Export the video composition to the output URL.
                        guard let export = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality) else {
                            print("can't set up AV export session")
                            return
                        }
                        export.outputFileType = .mov
                        export.outputURL = output.renderedContentURL
                        export.videoComposition = composition
                        export.exportAsynchronously(completionHandler: completionHandler)
                    }
                }
                /*
                 PHLivePhotoEditingContext : Uses CIImage frames, automatically converted
                */
                func CIImage_frames_auto_convert(){
                    // Editing a HEIF/HEVC live photo -- format handled automatically
                    func applyLivePhotoFilter(_ filterName: String, input: PHContentEditingInput, output: PHContentEditingOutput, completion: @escaping () -> Void) {
                        guard let livePhotoContext = PHLivePhotoEditingContext(livePhotoEditingInput: input) else {
                            fatalError("can't get live photo")
                        }
                        livePhotoContext.frameProcessor = { frame, _ in
                            return frame.image.applyingFilter(filterName)
                        }
                        livePhotoContext.saveLivePhoto(to: output) { success, error in
                            if !success {
                                print("can't output live photo, error:\(error!)"); return
                            }
                            completion()
                        }
                    }
                }
            }
        }
    }
    func Tiling_Support_in() {
        func CGImageSource() {
            /* image Properties e.g.
             "{TIFF}" = {
                 DateTime = "2017:04:01 22:50:24";
                 Make = Apple;
                 Model = "iPhone 7 Plus"; Orientation = 1;
                 ResolutionUnit = 2;
                 Software = "11.0";
                 TileLength = 512;
                 TileWidth = 512;
                 XResolution = 72;
                 YResolution = 72;
             };
             */
        }
        func CGImage(bigImage:CGImage,rect:CGRect) {
            let subImage = bigImage.cropping(to: rect)
            if subImage != nil {
                print(subImage!)
            }
        }
    }
}
extension HEVC : HEVC_Support {
    func AVCapturePhotoOutput_Supported_Formats() {
        func iOS_10_Image_Format() {
            /*
             Compressed Formats   : jpeg
             Uncompressed Formats : 420f/420v    BGRA
             RAW Formats          : grb4/rgg4/bgg4/gbr4
             */
        }
        func iOS_11() {
            /*
             Compressed Formats  : hvc1                 ->  HEIC
                                   jpeg                 ->  JFIF
             Uncompressed Formats: 420f/420v            ->  TIFF
                                   BGRA                 ->  TIFF
             RAW Formats         :grb4/rgg4/bgg4/gbr4   ->  DNG
             */
        }
    }
    //Photos During Video Capture
    func compare_with_h264() {
        /*
         HEVC/H.264 hardware resource contention
         
         Video is prioritized
         Photos are larger
         Consider using JPEG for photos
         time_encode: HEVC > JPEG
         JPEG is recommended when huge use
         */
    }
}
extension PHAsset {
    func converToAsset() -> AVAsset? {
        let semaphore = DispatchSemaphore(value: 0)
        var asset:AVAsset? = nil;
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.version = PHVideoRequestOptionsVersion.current
        options.deliveryMode = .highQualityFormat
        //仅当本地没有,isNetworkAccessAllowed为true时从iCloud下载,回调会被周期性地调用
        options.progressHandler = ({ (progress:Double, error:Error?, stop:UnsafeMutablePointer<ObjCBool>, info:[AnyHashable : Any]?) in
            print("progress:%lf",progress)
            if error != nil {
                print(error!)
            }
            stop.pointee = true
        })
        
        PHImageManager.default().requestAVAsset(forVideo: self, options: nil) { (avAsset, avAudioMix, dictionary) in
            asset = avAsset;
            semaphore.signal()
        }
        let result:DispatchTimeoutResult = semaphore.wait(timeout: DispatchTime.distantFuture)
        if result == .success {
            return asset;
        }
        let time:UInt64 = mach_absolute_time()
        let info:mach_timebase_info = mach_timebase_info(numer: 1, denom: 1)
        print(time,info)
        return nil;
    }
}
extension Date {
    func string() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm:ss.SS"
        return formatter.string(from: self)
    }
}
