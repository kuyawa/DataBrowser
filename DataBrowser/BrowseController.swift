//
//  BrowseController.swift
//  DataBrowser
//
//  Created by Mac Mini on 12/13/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa
import Foundation

class BrowseController: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var DB = Database()
    var tableName = ""
    var tableView : NSTableView?
    var fields    = DataResults()  //["name":"company", "type":"text", "length":40]
    var records   = DataResults()
    var schema    = DataSchema()
    
    var start = 0
    var limit = 100
    var total = 0
    
    func setContext(in db:Database) {
        DB = db
    }
    
    func getSchema() {
        if let fields = DB.schema(tableName) {
            //_ = fields.map{ $0.map{ print($0["name"]!, $0["type"]!) } }
            schema.parseFields(fields)
        }
    }
    
    func getRecords() {
        if let results = DB.browse(tableName) {
            records = results
            start   = 0
            limit   = 100
            total   = DB.recordCount(tableName)
        }
    }
    
    func getRecordCount() -> String {
        let ini = start
        var end = start + limit
        if end > records.count { end = start + records.count }
        return "Records \(ini+1) .. \(end) / \(total)"
    }
    
    func clear() {
        clearRows()
        clearColumns()
    }
    
    func clearRows() {
        if let last = tableView?.numberOfRows {
            //let range = NSRange(location: 0, length: last)
            let all = IndexSet(integersIn: 0 ..< last)
            tableView?.removeRows(at: all, withAnimation: .slideUp)
        }
    }
    
    func clearColumns() {
        if let table = tableView {
            for col in table.tableColumns {
                table.removeTableColumn(col)
            }
        }
    }
    
    func makeTable() {
        guard let tableView = tableView else { return }

        clearRows()
        clearColumns()
        
        var nib = NSNib(nibNamed: "BaseTableCell", bundle: .main)

        for field in schema.fields {
            let name = field.name
            var size = field.length * 2
            if size < 80 { size = 80 }    // Min
            if size > 300 { size = 300 }  // Max

            let col = NSTableColumn(identifier: name)
            col.headerCell.title = name
            col.headerCell.alignment = .center
            col.width = CGFloat(size)
            if col.width < 1.0 { col.width = 40.0 }
            tableView.addTableColumn(col)

            switch field.base {
            case .Text    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main)
            case .Integer : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Numeric : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Real    : nib = NSNib(nibNamed: "NumericTableCell", bundle: .main)
            case .Blob    : nib = NSNib(nibNamed: "BaseTableCell"   , bundle: .main)
            }
            
            tableView.register(nib, forIdentifier: name)
        }
        
        tableView.usesAlternatingRowBackgroundColors = true
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.target     = self
        tableView.font       = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: NSFontWeightRegular)
    }
    
    func reload() {
        tableView?.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item   = records[row]
        let cellId = (tableColumn?.identifier)!
        var text   = (item[cellId] as AnyObject).debugDescription!
        //var image: NSImage?
        
        switch item[cellId] {
        case let value as String   : text = value
        case let value as Int      : text = String(value)
        case let value as Double   : text = String(value)
        case let value as NSNumber : text = String(describing: value)
        default: text = "\(item[cellId]!)"
        }
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }

    func prev() {
        if start == 0 { return }
        start -= limit
        if start < 0 { start = 0 }
        
        if let results = DB.browse(tableName, start:start, limit:limit) {
            records = results
            reload()
        }
    }
    
    func next() {
        let edge = total - limit
        if start > edge { return }
        start += limit
        if start > total { start -= limit }
        
        if let results = DB.browse(tableName, start:start, limit:limit) {
            records = results
            reload()
        }
    }
    
}


// END
