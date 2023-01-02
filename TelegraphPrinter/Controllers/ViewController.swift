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
    
    private let telegraphApiClient: TelegraphService = TelegraphService()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func printAction(_ sender: Any) {
//        self.telegraphApiClient.createPage(title: "Test Page", content: [ "Was created...", "...automaticaly" ]) { (page, error) in
//            if let error = error {
//                self.outputView.string = error
//                return
//            }
//
//            self.outputView.string = page?.content?.joined(separator: "\n") ?? ""
//
//            print(page!.url, page!.title)
//        }
        self.outputView.string = self.inputView.string
    }

}
