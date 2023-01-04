//
//  ViewController.swift
//  TelegraphPrinter
//
//  Created by Airat K on 20/11/2022.
//

import Cocoa


class ViewController: NSViewController {
    
    @IBOutlet var inputView: NSTextView!
    @IBOutlet var outputView: NSTextView!
    @IBOutlet var progressCircle: NSProgressIndicator!
    
    private let telegraphClient = TelegraphService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func printAction(_ sender: Any) {
        self.dropOutputViewContent()
        
        guard !self.inputView.string.isEmpty else { return }
        
        let pagesRawContent = self.getPagesRawContentFromInputView()
        
        for (index, pageRawContent) in pagesRawContent.enumerated() {
            let (title, content) = self.getPageEntities(from: pageRawContent)
            
            guard !content.isEmpty else { continue }
            
            self.progressCircle.startAnimation(sender)
            self.telegraphClient.createPage(title: title, content: content) { (page, error) in
                if index == pagesRawContent.count - 1 {
                    self.progressCircle.stopAnimation(sender)
                }
                
                if let error = error {
                    self.appendOutputViewContent(withString: "Ошибка в обработке вопроса \"\(title)\": \(error)")
                    return
                }
                
                self.appendOutputViewContent(withString: self.telegraphClient.telegraphUrl + page!.path)
            }
        }
    }
    
    
    private func dropOutputViewContent() {
        self.outputView.string = ""
    }
    
    private func getPagesRawContentFromInputView() -> [String] {
        var pagesContent = self.inputView.string.split(regex: "\n\n[\t]*[0-9]+.[\t]*")
        
        pagesContent[0] = pagesContent[0].split(regex: "^[\t]*[0-9]+.[\t]*").last!
        
        return pagesContent
    }
    
    private func appendOutputViewContent(withString string: String) {
        self.outputView.string = self.outputView.string.appending(string + "\n")
    }
    
    private func getPageEntities(from pageRawContent: String) -> (title: String, content: [[String : Any]]) {
        let pageRawParagraphs = pageRawContent.split(regex: "[\n]+")
        
        let title = pageRawParagraphs[0].trimmingCharacters(in: CharacterSet(charactersIn: ".!0 \t"))
        let content = pageRawParagraphs[1...].filter { !$0.isEmpty } .map {
            [
                "tag": "p",
                "children": [ $0.trimmingCharacters(in: .whitespacesAndNewlines) ]
            ]
        }
        
        return (title, content)
    }

}
