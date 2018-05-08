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
 - make so that there are no delays in the loading of the resource, which prevents us from adding mechanisms to wait for the resources before taking the screenshots (and therefore make UITests faster)
 
 The class will try to find a matching file in one of the bundles. Given a url, files will be matched in the following order:
 - search a file that has the url as a name (e.g., http://example.com/image.png)
 - search a file that has the last path component as file name (e.g., image.png)
 - search a file that has the last path component without extension as file name (e.g., image)
 
 If the class is not able to locate the file, then it returns that it is not able to manage the request (and most likely a network
 request will occur)
*/
public final class LocalFileURLProtocol: URLProtocol, NSURLConnectionDataDelegate {
  private var connection: NSURLConnection?
  
  public override class func canInit(with request: URLRequest) -> Bool {
    guard let url = request.url else {
      return false
    }
    
    let isSupportedScheme = url.scheme == "http" || url.scheme == "https"
    let hasLocalResource = self.localURL(for: url) != nil
    return hasLocalResource && isSupportedScheme
  }
  
  public override class func canInit(with task: URLSessionTask) -> Bool {
    guard let request = task.currentRequest else {
      return false
    }
    
    return self.canInit(with: request)
  }
  
  public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  public override func startLoading() {
    guard
      let url = request.url,
      let localURL = LocalFileURLProtocol.localURL(for: url)

      else {
        return
    }

    print("CACHE: HANDLING \(url.absoluteString)")
    let req = URLRequest(url: localURL, cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 100)
    let connection = NSURLConnection(request: req, delegate: self, startImmediately: true)
    self.connection = connection
  }
  
  public override func stopLoading() {
    self.connection?.cancel()
  }
  
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

  // MARK: NSURLConnectionDataDelegate
  public func connection(_ connection: NSURLConnection, willCacheResponse cachedResponse: CachedURLResponse) -> CachedURLResponse? {
    return cachedResponse
  }
  
  public func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest? {
    return request
  }

  public func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
  }
  
  public func connection(_ connection: NSURLConnection, didReceive data: Data) {
    self.client?.urlProtocol(self, didLoad: data)
  }
  
  public func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
    self.client?.urlProtocol(self, didFailWithError: error)
    self.connection = nil
  }

  public func connectionDidFinishLoading(_ connection: NSURLConnection) {
    self.client?.urlProtocolDidFinishLoading(self)
    self.connection = nil
  }
  
  deinit {
    self.connection?.cancel()
    self.connection = nil
  }
}

private extension String {
  /// Assuming the string is a file path, it returns the mime type of the represented file
  var mimeType: String? {
    let url = NSURL(fileURLWithPath: self)
    let pathExtension = url.pathExtension
    
    if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
      if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
        return mimetype as String
      }
    }
    
    return nil
  }
}
