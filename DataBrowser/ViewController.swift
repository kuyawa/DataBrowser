//
//  ViewController.swift
//  DataBrowser
//
//  Created by Mac Mini on 12/12/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOpenSavePanelDelegate {

    var DB      = Database()
    var tables  = TableController()
    var browser = BrowseController()
    
    @IBOutlet weak var databaseName : NSTextField!
    @IBOutlet weak var tableView    : NSTableView!
    @IBOutlet weak var browseView   : NSTableView!
    
    @IBOutlet weak var numTables    : NSTextField!
    @IBOutlet weak var numRecords   : NSTextField!
    
    
    @IBAction func onSelectDatabase(_ sender: AnyObject) {
        let dialog = NSOpenPanel()
        let choice = dialog.runModal()
        if choice == NSFileHandlingPanelOKButton {
            if let file = dialog.url {
                DispatchQueue.main.async {
                    self.openDatabase(file)
                }
            }
        }
    }
    
    @IBAction func onSelectTable(_ sender: AnyObject) {
        let index = tableView.selectedRow
        let name  = tables.list[index]
        browseTable(name)
    }
    
    @IBAction func onPrevRecords(_ sender: AnyObject) {
        browser.prev()
        showRecordCount()
    }
    
    @IBAction func onNextRecords(_ sender: AnyObject) {
        browser.next()
        showRecordCount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func initialize() {
        setupTableView()
        openLastDatabase()
    }
    
    func setupTableView() {
        tables = TableController()
        tables.assign(tableView)
        tables.setSelectionMethod(browseTable)
    }
    
    func openLastDatabase() {
        if let dbUrl = UserDefaults.standard.url(forKey: "lastdb") {
            openDatabase(dbUrl)
        } else {
            if let dbTest = copyTestDatabase() {
                openDatabase(dbTest)
            }
        }
    }
    
    func copyTestDatabase() -> URL? {
        let filer = FileManager.default
        
        do {
            let docs   = filer.urls(for: .documentDirectory, in: .userDomainMask).first!
            let source = Bundle.main.url(forResource: "Test", withExtension: "db")!
            let target = docs.appendingPathComponent("Test.db")
            print("Copying test database to \(target)...")
            try filer.copyItem(at: source, to: target)
            return target
        } catch {
            print("Error copying test database")
            print(error)
        }
        
        return nil
    }
    
    func openDatabase(_ name: URL) {
        DB.open(file: name)
        
        if DB.isConnected() {
            saveLastDatabase(name)
            showDatabaseName(DB.filename)
            tables.list = DB.getTables()
            showTables()
            showTableCount()
            selectFirstTable()
        } else {
            showDatabaseName("<Error>")
            print("Error connecting to database")
            // Alert user
        }

    }
    
    func saveLastDatabase(_ name: URL) {
        UserDefaults.standard.set(name, forKey: "lastdb")
    }

    func showDatabaseName(_ name: String) {
        databaseName.stringValue = name
    }
    
    func showTables() {
        tables.reload()
    }
    
    func showTableCount() {
        numTables.stringValue = tables.list.count.plural("Table")
    }
    
    func showRecordCount() {
        numRecords.stringValue = browser.getRecordCount()
    }
    
    func selectFirstTable() {
        if tables.list.count > 0 {
            let first = tables.list.first!
            browseTable(first)
        }
    }
    
    func browseTable(_ name: String) {
        if name.isEmpty { return }
        // show records
        browser.tableView = browseView
        browser.tableName = name
        browser.setContext(in: DB)
        browser.getSchema()
        browser.getRecords()
        browser.makeTable()
        browser.reload()
        showRecordCount()
    }
}

extension Int {
    func plural(_ text: String) -> String {
        let word = text + (self == 1 ? "" : "s")
        return("\(self) \(word)")
    }
}

// END
