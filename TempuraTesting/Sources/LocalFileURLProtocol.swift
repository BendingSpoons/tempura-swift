//
//  LocalFileURLProtocol.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

//
//  LocalResourceURLProtocol.swift
//  TempuraTesting
//
//  Created by Mauro Bolis on 07/05/2018.
//
import Foundation
import MobileCoreServices

/**
 Custom URLProtocol that can be used to load local resources instead of remote ones during UITests.
 This behaviour has several advantages:
 - make UITests independent from server status, network connection and related topics
 - make so that there are no delays in the loading of the resource, which prevents us from adding mechanisms to wait for the
   resources before taking the screenshots (and therefore make UITests faster)

 The class will try to find a matching file in one of the bundles. Given a url, files will be matched in the following order:
 - search a file that has the url as a name (e.g., http://example.com/image.png)
 - search a file that has the last path component as file name (e.g., image.png)
 - search a file that has the last path component without extension as file name (e.g., image)

 If the class is not able to locate the file, then it returns that it is not able to manage the request (and most likely a network
 request will occur)
 */
public final class LocalFileURLProtocol: URLProtocol, NSURLConnectionDataDelegate {
  override public class func canInit(with request: URLRequest) -> Bool {
    guard let url = request.url else {
      return false
    }

    let isSupportedScheme = url.scheme == "http" || url.scheme == "https"
    let hasLocalResource = self.localURL(for: url) != nil
    return hasLocalResource && isSupportedScheme
  }

  override public class func canInit(with task: URLSessionTask) -> Bool {
    guard let request = task.currentRequest else {
      return false
    }

    return self.canInit(with: request)
  }

  override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override public func startLoading() {
    guard let client = self.client,
          let url = request.url,
          let localURL = LocalFileURLProtocol.localURL(for: url),
          let data = try? Data(contentsOf: localURL)

    else {
      return
    }

    // swiftlint:disable:next force_unwrapping
    let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!

    client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
    client.urlProtocol(self, didLoad: data)
    client.urlProtocolDidFinishLoading(self)
  }

  override public func stopLoading() {}

  /**
   Returns a local path (if any) that matches the requested url
   - parameter url: the requested url
   */
  private static func localURL(for url: URL) -> URL? {
    let absoluteURL = url.absoluteString
    let fileName = url.lastPathComponent
    let fileNameWithoutExtension = url.deletingPathExtension().lastPathComponent

    for bundle in Bundle.allBundles {
      if let url = bundle.url(forResource: absoluteURL, withExtension: nil) {
        return url
      } else if let url = bundle.url(forResource: fileName, withExtension: nil) {
        return url
      } else if let url = bundle.url(forResource: fileNameWithoutExtension, withExtension: nil) {
        return url
      }
    }

    return nil
  }
}

extension String {
  /// Assuming the string is a file path, it returns the mime type of the represented file
  private var mimeType: String? {
    let url = NSURL(fileURLWithPath: self)
    let pathExtension = url.pathExtension

    // swiftlint:disable:next force_unwrapping
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?
      .takeRetainedValue() {
      if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
        return mimetype as String
      }
    }

    return nil
  }
}
