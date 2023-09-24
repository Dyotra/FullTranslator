//
//  TranslationVC.swift
//  FullTranslator
//
//  Created by Bekpayev Dias on 22.09.2023.
//

import Foundation
import UIKit
import Alamofire

class Translator {
    let apiKey = "trnsl.1.1.20230922T134655Z.431081722b9e94bb.6e52d2fc439ddd180c7b95fe9cf3364177b8714c"
    let baseURL = "https://translate.yandex.net/api/v1.5/tr.json/translate"
    
    func translateText(direction: String, text: String, translatedResult: @escaping (String) -> Void) {
        let parameters: [String: Any] = [
            "key": apiKey,
            "text": text,
            "lang": direction,
            "format": "plain",
            "options": 1
        ]
        AF.request(baseURL, method: .post, parameters: parameters).response { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                let decodedData = try? decoder.decode(YandexResponse.self, from: data!)
                if let text = decodedData?.text.first {
                    translatedResult(text)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct YandexResponse: Codable {
    let code: Int
    let lang: String
    let text: [String]
}
