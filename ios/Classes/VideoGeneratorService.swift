import Foundation
import AVFoundation
import Photos
import Flutter

public protocol VideoGeneratorServiceInterface {
    func writeVideofile(srcPath:String, destPath:String, processing: [String: [String:Any]], result: @escaping FlutterResult, eventSink : FlutterEventSink?)
    func cancelCompression( result: @escaping FlutterResult)
}

public class VideoGeneratorService: VideoGeneratorServiceInterface {
      private var exporter: AVAssetExportSession? = nil
    public func writeVideofile(srcPath:String, destPath:String, processing: [String: [String:Any]], result: @escaping FlutterResult, eventSink : FlutterEventSink?) {
        let fileURL = URL(fileURLWithPath: srcPath)

        let composition = AVMutableComposition()
        let vidAsset = AVURLAsset(url: fileURL)

        // get video track
        print("aaasd")
        let videoTrack: AVAssetTrack = vidAsset.tracks(withMediaType: .video)[0]
        print("tabunn")
        let vidTimerange = CMTimeRangeMake(start: CMTime.zero, duration: vidAsset.duration)

        guard let compositionvideoTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            result(FlutterError(code: "video_processing_failed",
                                message: "composition.addMutableTrack is failed.",
                                details: nil))
            return
        }
        do {
            try compositionvideoTrack.insertTimeRange(vidTimerange, of: videoTrack, at: .zero)
            if let audioAssetTrack = vidAsset.tracks(withMediaType: .audio).first,
               let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid) {
                try compositionAudioTrack.insertTimeRange(
                    vidTimerange,
                    of: audioAssetTrack,
                    at: .zero)
            }
        } catch {
            print(error)
            result(FlutterError(code: "video_processing_failed",
                                message: "compositionvideoTrack is failed.",
                                details: nil))
            return
        }

        compositionvideoTrack.preferredTransform = videoTrack.preferredTransform
        let size = videoTrack.naturalSize

        let layercomposition = AVVideoComposition(asset: composition) { (filteringRequest) in
            var source = filteringRequest.sourceImage.clampedToExtent()
            for (key, value) in processing  {
                switch key {
                case "Filter":
                    guard let type = value["type"] as? String,
                       let alpha = value["alpha"] as? Double else {
                        print("not found value")
                        result(FlutterError(code: "processing_data_invalid",
                                            message: "one Filter member is not found.",
                                            details: nil))
                        return
                    }

                    let overlayColor = UIColor(hex: type.replacingOccurrences(of: "#", with: ""), alpha: alpha)
                    let c = CIColor(color: overlayColor)
                    guard let colorFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: c]) else {
                        fatalError()
                    }
                    let parameters = [
                        kCIInputBackgroundImageKey: source,
                        kCIInputImageKey: colorFilter.outputImage!
                    ]
                    guard let filter = CIFilter(name: "CISourceOverCompositing", parameters: parameters) else {
                        fatalError()
                    }
                    guard let outputImage = filter.outputImage else { fatalError() }
                    let cropRect = source.extent
                    source = outputImage.cropped(to: cropRect)

                case "TextOverlay":
                    guard let text = value["text"] as? String,
                          let x = value["x"] as? NSNumber,
                          let y = value["y"] as? NSNumber,
                          let textSize = value["size"] as? NSNumber,
                          let color = value["color"] as? String else {
                        print("not found text overlay")
                        result(FlutterError(code: "processing_data_invalid",
                                            message: "one TextOverlay member is not found.",
                                            details: nil))
                        return
                    }
                    let font = UIFont.boldSystemFont(ofSize: CGFloat(truncating: textSize))
                    
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: UIColor(hex:color.replacingOccurrences(of: "#", with: ""),alpha: 1),
                    ]

                    let attributedQuote = NSAttributedString(string: text, attributes: attributes)
                    let textGenerationFilter = CIFilter(name: "CIAttributedTextImageGenerator")!
                    textGenerationFilter.setValue(attributedQuote, forKey: "inputText")
                    let textImage = textGenerationFilter.outputImage!
                    let transform = CGAffineTransform(translationX: CGFloat(truncating: x), y: filteringRequest.sourceImage.extent.height - CGFloat(truncating: textSize) - CGFloat(truncating: y))

                     // Calculate the time-based display range
//                     let currentTimeInSeconds = CMTimeGetSeconds(filteringRequest.compositionTime)
//                     let currentTimeInMilliseconds = currentTimeInSeconds * 1000
//                        let displayStartTime = start
//                        let displayEndTime = start + duration

                        // Check if the current time falls within the display range
//                        if currentTimeInMilliseconds >= displayStartTime && currentTimeInMilliseconds <= displayEndTime {
//                            source = textImage
//                                .transformed(by: transform)
//                                .applyingFilter("CISourceAtopCompositing", parameters: [kCIInputBackgroundImageKey: source])
//                        }
                        source = textImage
                                .transformed(by: transform)
                                .applyingFilter("CISourceAtopCompositing", parameters: [kCIInputBackgroundImageKey: source])
//                    source = textGenerationFilter.outputImage!.transformed(by: CGAffineTransform(translationX: CGFloat(truncating: x), y: filteringRequest.sourceImage.extent.height -  CGFloat(textSize) - CGFloat(truncating: y)))
//                        .applyingFilter("CISourceAtopCompositing", parameters: [ kCIInputBackgroundImageKey: source])
                case "ImageOverlay":
                    guard let bitmap = value["bitmap"] as? FlutterStandardTypedData,
                          let x = value["x"] as? NSNumber,
                          let y = value["y"] as? NSNumber else {
                        print("not found image overlay")
                        result(FlutterError(code: "processing_data_invalid",
                                            message: "one ImageOverlay member is not found.",
                                            details: nil))
                        return
                    }
                    let imageFilter = CIFilter(name: "CISourceOverCompositing")!
                    guard let watermarkImage = CIImage(data: bitmap.data) else {
                        result(FlutterError(code: "video_processing_failed",
                                            message: "creating TextImage is failed.",
                                            details: nil))
                        return
                    }
                    imageFilter.setValue(source, forKey: "inputBackgroundImage")
                    let transform = CGAffineTransform(translationX: filteringRequest.sourceImage.extent.width - watermarkImage.extent.width - CGFloat(truncating: x), y:  CGFloat(truncating: y) - filteringRequest.sourceImage.extent.height)
                    imageFilter.setValue(watermarkImage.transformed(by: transform), forKey: "inputImage")
                    source = imageFilter.outputImage!
                default:
                    print("Not implement filter name")
                }
            }
            filteringRequest.finish(with: source, context: nil)
        }
        let movieDestinationUrl = URL(fileURLWithPath: destPath)
        let preset: String = AVAssetExportPresetHighestQuality
        guard let assetExport = AVAssetExportSession(asset: composition, presetName: preset) else {
            print("assertExport error")
            result(FlutterError(code: "video_processing_failed",
                                message: "init AVAssetExportSession is failed.",
                                details: nil))
            return
        }
        assetExport.outputFileType = .mp4
        assetExport.videoComposition = layercomposition

        assetExport.outputURL = movieDestinationUrl
         var exportProgressBarTimer = Timer() // initialize timer
                        if #available(iOS 10.0, *) {
                            exportProgressBarTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            // Get Progress
                            let progress = Float((assetExport.progress));
                            if (progress < 0.99 && eventSink != nil) {
                                eventSink!(progress * 100)
                            }
                          }
                        }
        assetExport.exportAsynchronously{
            switch assetExport.status{
            case .completed:
                print("Movie complete")
                self.exporter = nil
                result(nil)
            case  .failed:
                self.exporter = nil
                print("failed \(String(describing: assetExport.error))")
            case .cancelled:
                self.exporter = nil

                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("cancelled \(String(describing: assetExport.error))")
                break
            }
        }
        exporter = assetExport
    }
     public func cancelCompression(result: FlutterResult) {
            exporter?.cancelExport()
            result(nil)
        }
}

extension UIColor {
    convenience init(hex: String, alpha: Double) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
}

struct Filter {
    let type: String
    let alpha: Double
}

struct ImageOverlay {
    let bitmap: Data
    let x: NSNumber
    let y: NSNumber
}

struct TextOverlay {
    let text: String
    let x: NSNumber
    let y: NSNumber
    let size: NSNumber
    let color: String
    let start: NSNumber
    let duration: NSNumber
}
