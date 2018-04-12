import Foundation

func buildText(from text: String) -> [Unicode.Scalar: Float64] {
    var result: [Unicode.Scalar: Float64] = [:]

    for char in Array(text.unicodeScalars) {

        if let value = result[char] {
            result[char] = value + 1

        } else {
            result[char] = 1
        }
    }

    for char in result {
        result[char.key] = char.value / Float64(text.count)
    }

    return result
}

func readText(from fileName: String) -> [Unicode.Scalar: Float64] {

    guard  let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt")
        else { return [:] }

    let content = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    var result: [Unicode.Scalar: Float64] = [:]

    if let content = content {
            result = buildText(from: content)
    }

    return result
}

func decodeHex(from hexString: String) -> [UInt8] {

    if hexString.count & 1 != 0 {
        return [0]
    }

    var index = hexString.startIndex
    var result : [UInt8] = []

    for _ in  0..<hexString.count / 2 {

        let nextIndex = hexString.index(index, offsetBy: 2)

        if let hexDecodedValue = UInt8(hexString[index..<nextIndex], radix: 16) {

            result.append(hexDecodedValue)
        }

        index = nextIndex
    }
    return result
}

func scoreEnglishLetter(text: String, characterFrequency: [Unicode.Scalar: Float64]) -> Float64 {

    var score: Float64 = 0
    for char in text.unicodeScalars {
        if let frequency = characterFrequency[char] {
            score += frequency
        }
    }

    return score / Float64(text.count)
}

func singleXOR(from hexDecodedValue: [UInt8], key: UInt8) -> [UInt8] {
    var result = [UInt8](repeating: 0, count: hexDecodedValue.count)

    for (index, value) in hexDecodedValue.enumerated() {
        result[index] = value ^ key
    }

    return result
}

func findSingleXORkey(from hexDecodedValue: [UInt8], characterFrequency: [Unicode.Scalar: Float64]) -> [UInt8] {

    var lastScore: Float64 = 0

    var result: [UInt8] = []

    for key in 0..<256 {
        let output = singleXOR(from: hexDecodedValue, key: UInt8(key))
        if let string =  String(bytes: output, encoding: .utf8) {
            let score = scoreEnglishLetter(text:  string, characterFrequency: characterFrequency)

            if score > lastScore {
                result = output
                lastScore = score
            }
        }
    }

    return result
}

func test() {
    let letterFrequency = readText(from: "aliceInWonderland")

    let result = findSingleXORkey(from:
        decodeHex(from: "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"),
                                  characterFrequency: letterFrequency)

    if let string = String(bytes: result, encoding: .utf8) {
        print(string)
    }
}

test()










