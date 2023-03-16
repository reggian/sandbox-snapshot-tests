//
// Copyright © 2023 reggian
//

import XCTest

extension XCTestCase {
  func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    
    guard let snapshotData = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return
    }
    
    guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
      XCTFail("Failed to load stored snapshot at URL: \(snapshotURL). Use the `record` method to store a snapshot before asserting.", file: file, line: line)
      return
    }
    
    if !match(snapshotData, storedSnapshotData, perPixelTolerance: 0.004, overAllTolerance: 0.00001) {
      let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        .appendingPathComponent(snapshotURL.lastPathComponent)
      
      try? snapshotData.write(to: temporarySnapshotURL)
      
      XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(snapshotURL)", file: file, line: line)
    }
  }
  
  func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
    let snapshotURL = makeSnapshotURL(named: name, file: file)
    
    guard let snapshotData = snapshot.pngData() else {
      XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
      return
    }
    
    do {
      try FileManager.default.createDirectory(
        at: snapshotURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
      
      try snapshotData.write(to: snapshotURL)
      XCTFail("Record succeeded - use `assert` to compare the snapshot from now on.", file: file, line: line)
    } catch {
      XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
    }
  }
}

// MARK: - Private
private extension XCTestCase {
  func makeSnapshotURL(named name: String, file: StaticString) -> URL {
    return URL(fileURLWithPath: String(describing: file))
      .deletingLastPathComponent()
      .appendingPathComponent("snapshots")
      .appendingPathComponent("\(name).png")
  }
  
  func match(_ oldData: Data, _ newData: Data, perPixelTolerance: Float = 0, overAllTolerance: Float = 0) -> Bool {
    if oldData == newData { return true }
    
    guard let oldImage = UIImage(data: oldData)?.cgImage, let newImage = UIImage(data: newData)?.cgImage else {
      return false
    }
    
    guard oldImage.width == newImage.width, oldImage.height == newImage.height else {
      return false
    }
    
    let minBytesPerRow = min(oldImage.bytesPerRow, newImage.bytesPerRow)
    let bytesCount = minBytesPerRow * oldImage.height
    
    var oldImageByteBuffer = [UInt8](repeating: 0, count: bytesCount)
    guard let oldImageData = data(for: oldImage, bytesPerRow: minBytesPerRow, buffer: &oldImageByteBuffer) else {
      return false
    }
    
    var newImageByteBuffer = [UInt8](repeating: 0, count: bytesCount)
    guard let newImageData = data(for: newImage, bytesPerRow: minBytesPerRow, buffer: &newImageByteBuffer) else {
      return false
    }
    
    if memcmp(oldImageData, newImageData, bytesCount) == 0 { return true }
    
    return match(oldImageByteBuffer, newImageByteBuffer, perPixelTolerance: perPixelTolerance, overAllTolerance: overAllTolerance, bytesCount: bytesCount)
  }
  
  func data(for image: CGImage, bytesPerRow: Int, buffer: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    guard
      let space = image.colorSpace,
      let context = CGContext(
        data: buffer,
        width: image.width,
        height: image.height,
        bitsPerComponent: image.bitsPerComponent,
        bytesPerRow: bytesPerRow,
        space: space,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
      )
    else { return nil }
    
    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    
    return context.data
  }
  
  func match(_ bytes1: [UInt8], _ bytes2: [UInt8], perPixelTolerance: Float, overAllTolerance: Float, bytesCount: Int) -> Bool {
    let perPixelTolerance = Int(perPixelTolerance * 255)
    let overAllTolerance = Int(overAllTolerance * Float(bytesCount))
    var differentBytesCount = 0
    
    return bytes1.withUnsafeBufferPointer { bytes1Ptr in
      return bytes2.withUnsafeBufferPointer { bytes2Ptr in
        for i in 0 ..< bytesCount where !match(bytes1Ptr[i], bytes2Ptr[i], perPixelTolerance: perPixelTolerance) {
          differentBytesCount += 1
          if differentBytesCount > overAllTolerance {
            return false
          }
        }
        return true
      }
    }
  }
  
  func match(_ byte1: UInt8, _ byte2: UInt8, perPixelTolerance: Int) -> Bool {
    if byte1 == byte2 {
      return true
    } else if perPixelTolerance == 0 {
      return false
    }
    
    let diff = Int(byte1) &- Int(byte2)
    return diff <= perPixelTolerance && diff >= -perPixelTolerance
  }
}
