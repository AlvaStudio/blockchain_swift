//: Playground - noun: a place where people can play

import Cocoa

class Block {
    
    var index :Int = 0
    var dateCreated :String
    var previousHash :String!
    var hash :String!
    var nonce :Int
    
    var key :String {
        get {
            return String(self.index) + self.dateCreated + self.previousHash + String(self.nonce)
        }
    }
    
    init() {
        self.dateCreated = Date().toString()
        self.nonce = 0
    }
    
    
}

class Blockchain {
    
    private (set) var blocks :[Block] = [Block]()
    
    init(_ genesisBlock :Block) {
        
        addBlock(genesisBlock)
    }
    
    func addBlock(_ block :Block) {
        
        if self.blocks.isEmpty {
            // add the genesis block
            // no previous has was found for the first block
            block.previousHash = "0"
            block.hash = generateHash(for: block)
        } else {
            let previousBlock = getPreviousBlock()
            block.previousHash = previousBlock.hash
            block.index = self.blocks.count
            block.hash = generateHash(for: block)
        }
        
        self.blocks.append(block)
        displayBlock(block)
    }
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    
    private func displayBlock(_ block :Block) {
        print("------ Block \(block.index) ---------")
        print("Date Created : \(block.dateCreated) ")
        print("Nonce : \(block.nonce) ")
        print("Previous Hash : \(block.previousHash!) ")
        print("Hash : \(block.hash!) ")
        
    }
    
    private func generateHash(for block: Block) -> String {
        
        var hash = block.key.sha1Hash()
        
        while(!hash.hasPrefix("00")) {
            block.nonce += 1
            hash = block.key.sha1Hash()
        }
        
        return hash
    }
    
}

// String Extension
extension String {
    
    func sha1Hash() -> String {
        
        let task = Process()
        task.launchPath = "/usr/bin/shasum"
        task.arguments = []
        
        let inputPipe = Pipe()
        
        inputPipe.fileHandleForWriting.write(self.data(using: String.Encoding.utf8)!)
        
        inputPipe.fileHandleForWriting.closeFile()
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = inputPipe
        task.launch()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: data, encoding: String.Encoding.utf8)!
        return hash.replacingOccurrences(of: "  -\n", with: "")
    }
}

extension Date {
    
    func toString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
}

let block1 = Block()
let blockchain = Blockchain(block1)

for index in 1...5 {
    let block = Block()
    blockchain.addBlock(block)
}

