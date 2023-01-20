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
    @IBOutlet weak var sortButton: NSButton!
    
    private let telegraphClient = TelegraphService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func print(_ sender: Any) {
        self.dropOutputViewContent()
        
        guard !self.inputView.string.isEmpty else { return }
        
        self.progressCircle.startAnimation(sender)
        self.sortButton.isEnabled = false
        
        let pagesRawContent = self.getPagesRawContentFromInputView()
        
        for (index, pageRawContent) in pagesRawContent.enumerated() {
            let (title, content) = self.getPageEntities(from: pageRawContent)
            
            guard !content.isEmpty else { continue }
            
            self.telegraphClient.createPage(title: title, content: content) { (page, error) in
                if let error = error {
                    self.appendOutputViewContent(withString: "Ошибка в обработке вопроса \"\(title)\": \(error)")
                    self.stopProgessAnimationOnLastArticle(currentIndex: index, totalEntitiesNumber: pagesRawContent.count, sender: sender)
                    return
                }
                
                self.appendOutputViewContent(withString: self.telegraphClient.telegraphUrl + page!.path)
                self.stopProgessAnimationOnLastArticle(currentIndex: index, totalEntitiesNumber: pagesRawContent.count, sender: sender)
            }
        }
    }
    
    @IBAction func sort(_ sender: Any) {
        let lines = self.outputView.string.split(separator: "\n")
        let sortedLines = lines.sorted {
            self.getQuestionNumberFromUrl(String($0)) < self.getQuestionNumberFromUrl(String($1))
        }
        
        self.outputView.string = sortedLines.joined(separator: "\n")
    }
    
    private func dropOutputViewContent() {
        self.outputView.string = ""
    }
    
    private func getPagesRawContentFromInputView() -> [String] {
        return self.inputView.string.split(regex: "\n\n\n[\n]*")
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
    
    private func appendOutputViewContent(withString string: String) {
        self.outputView.string = self.outputView.string.appending(string + "\n")
    }
    
    private func stopProgessAnimationOnLastArticle(currentIndex: Int, totalEntitiesNumber: Int, sender: Any) {
        guard (currentIndex + 1) >= totalEntitiesNumber else { return }
        
        self.progressCircle.stopAnimation(sender)
        self.sortButton.isEnabled = true
    }
    
    private func getQuestionNumberFromUrl(_ urlString: String) -> Int {
        let questionTitle = urlString.trimmingCharacters(in: CharacterSet(charactersIn: telegraphClient.telegraphUrl))
        let rawQuestiongNumber = questionTitle.split(separator: "-", maxSplits: 1).first!
        
        return Int(rawQuestiongNumber) ?? Int.max
    }

}
