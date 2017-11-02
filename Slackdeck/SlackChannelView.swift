//
//  SlackChannelView.swift
//  Slackdeck
//
//  Created by mzp on 2017/04/29.
//  Copyright © 2017 mzp. All rights reserved.
//

import Cocoa
import WebKit

class SlackChannelView: WKWebView, WKNavigationDelegate, WKUIDelegate {
    init(configuration : WKWebViewConfiguration) {
        super.init(frame: .zero, configuration: configuration)
        self.navigationDelegate = self
        self.uiDelegate = self
        self.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
	}

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadURL(url : String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            self.load(request)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        insertContentsOfCSSFile(into: webView)
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame else {
            if isSlackTeam(url: url.absoluteString) {
                self.loadURL(url: url.absoluteString)
            } else {
                NSWorkspace.shared.open(url)
            }
            return nil
        }
        return nil
    }

    private func insertContentsOfCSSFile(into webView: WKWebView) {
        guard let path = Bundle.main.path(forResource: "styles", ofType: "css") else {
            return
        }
        guard let cssString = try? String(contentsOfFile: path).replacingOccurrences(of: "\n", with: "") else {
            return
        }
        evaluateJavaScript("var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style); null")
        evaluateJavaScript("window.__style__ = document.createElement('style'); document.head.appendChild(__style__); null")
    }

    private func isSlackTeam(url : String) -> Bool {
        let range = url.range(of: "^https://.*\\.slack\\.com/$", options: .regularExpression)
        return range != nil
    }

    override func becomeFirstResponder() -> Bool {
        evaluateJavaScript("__style__.innerHTML = '.ql-editor { }'; null")
        return super.becomeFirstResponder()
    }

    override func resignFirstResponder() -> Bool {
        evaluateJavaScript("__style__.innerHTML = '.ql-editor { background-color: #efefef }'; null")
        return super.becomeFirstResponder()
    }
}
