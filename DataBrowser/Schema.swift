//
//  Schema.swift
//  DataBrowser
//
//  Created by Mac Mini on 12/14/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Foundation

enum FieldTypePrimitive: String {
    case Text, Integer, Numeric, Real, Blob
}

enum FieldType: String {
    case Text, Varchar, NVarchar, Character, NChar, Clob,
         Int, Integer, TinyInt, SmallInt, MediumInt, BigInt, Uint, Int2, Int8,
         Real, Double, Float, Number, Numeric, Decimal,
         Date, Datetime,
         Boolean,
         Binary, Blob
}

class DataSchema: NSObject {
    var tableName = ""
    var fields    = [TableField]()
    var indexes   = [TableIndexes]()

    
    func parseFields(_ cols: DataResults) {
        fields.removeAll()
        
        for item in cols {
            let field = TableField()
            field.name = item["name"] as! String
            let (base, type, length, decs) = parseType(item["type"] as! String)
            field.base     = base
            field.type     = type
            field.length   = length
            field.decimals = decs
            // TODO: other field info like def value, auto, isnull
            
            fields.append(field)
        }
    }
    
    func parseType(_ field: String) -> (FieldTypePrimitive, FieldType, Int, Int) {
        let text   = field.uppercased()
        var base   = FieldTypePrimitive.Text
        var type   = FieldType.Varchar
        var length = 1
        var decs   = 0
        
        // Type
        if text.hasPrefix("TEXT")          { type = .Text;     base = .Text;    length = 40 }
        else if text.hasPrefix("VARCHAR")  { type = .Varchar;  base = .Text;    length = 40 }
        else if text.hasPrefix("NVARCHAR") { type = .NVarchar; base = .Text;    length = 40 }
        else if text.hasPrefix("INTEGER")  { type = .Integer;  base = .Integer; length = 12 }
        else if text.hasPrefix("NUMBER")   { type = .Numeric;  base = .Numeric; length = 12 }
        else if text.hasPrefix("NUMERIC")  { type = .Numeric;  base = .Numeric; length = 12 }
        else if text.hasPrefix("REAL")     { type = .Real;     base = .Real;    length = 12 }
        else if text.hasPrefix("DATETIME") { type = .Datetime; base = .Text;    length = 20 }
        else if text.hasPrefix("DATE")     { type = .Date;     base = .Text;    length = 20 }
        else if text.hasPrefix("BOOL")     { type = .Boolean;  base = .Integer; length = 20 }
        else if text.hasPrefix("BINARY")   { type = .Binary;   base = .Blob;    length = 40 }
        else if text.hasPrefix("BLOB")     { type = .Binary;   base = .Blob;    length = 40 }
        else { type = .Text; base = .Text; length = 40 }
        // Types: Point? Multipoint? Linestring?
        
        // Length
        if text.contains("(") {
            let size = text.components(separatedBy: "(")[1].components(separatedBy: ")")[0]
            if size.contains(",") {
                let parts = size.components(separatedBy: ",")
                length = Int(parts[0])!
                decs = Int(parts[1])!
            } else {
                length = Int(size)!
            }
        }
        
        return (base, type, length, decs)
    }
    


}

class TableField: NSObject {
    var name     = ""
    var base     = FieldTypePrimitive.Text
    var type     = FieldType.Text
    var length   = 1
    var decimals = 0
    var defValue = ""
    var isNull   = false
    var autoInc  = false
    var primary  = false
}

// TODO: indexes?
class TableIndexes: NSObject {
    var name = ""
}

