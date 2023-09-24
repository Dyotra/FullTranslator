//
//  FullTranslatorTests.swift
//  FullTranslatorTests
//
//  Created by Bekpayev Dias on 24.09.2023.
//

import XCTest
@testable import FullTranslator

final class FullTranslatorTests: XCTestCase {
    let translator = Translator()
    
    func testTranslation() {
            let expectation = self.expectation(description: "Translation")
            
            translator.translateText(direction: "es", text: "Привет") { translation in
                XCTAssertEqual(translation, "Hola")
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 1, handler: nil)
        }

}
