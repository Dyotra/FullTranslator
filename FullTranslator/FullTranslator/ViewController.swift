//
//  ViewController.swift
//  FullTranslator
//
//  Created by Bekpayev Dias on 19.09.2023.
//

import UIKit
import Foundation
import SnapKit
import Alamofire
import AVFoundation

class ViewController: UIViewController {
    
    let translator = Translator()
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    let backgroundImage: UIImageView = {
        let backgroundImage = UIImageView(image: UIImage(named: "Background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        return backgroundImage
    }()
    
    
    let textView1: UITextView = {
        let text = UITextView()
        text.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        text.textColor = UIColor.black
        text.font = UIFont(name: "Times New Roman Bold", size: 25)
        text.layer.cornerRadius = 10
        text.layer.borderWidth = 1
        text.tintColor = UIColor.blue
        text.selectedTextRange = text.textRange(from: text.beginningOfDocument, to: text.beginningOfDocument)
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.clipsToBounds = true
        text.indicatorStyle = .black
        return text
    }()
    
    let textView2: UITextView = {
        let text = UITextView()
        text.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        text.textColor = UIColor.black
        text.font = UIFont(name: "Times New Roman Bold", size: 25)
        text.layer.cornerRadius = 10
        text.layer.borderWidth = 1
        text.tintColor = UIColor.blue
        text.selectedTextRange = text.textRange(from: text.beginningOfDocument, to: text.beginningOfDocument)
        text.layer.borderColor = UIColor.lightGray.cgColor
        text.clipsToBounds = true
        text.indicatorStyle = .black
        return text
    }()
    
    let languageButton1: UIButton = {
        let button = UIButton()
        button.setTitle("Выбрать язык перевода", for: .normal)
        button.setTitleColor(.systemCyan, for: .normal)
        button.titleLabel?.font = UIFont(name: "Times New Roman Bold", size: 30)
        button.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        button.addTarget(self, action: #selector(languageButton1Tapped), for: .touchUpInside)
        button.layer.cornerRadius = 20
        return button
    }()
    
    let languageButton2: UIButton = {
        let button = UIButton()
        button.setTitle("Выбрать язык перевода", for: .normal)
        button.setTitleColor(.systemCyan, for: .normal)
        button.titleLabel?.font = UIFont(name: "Times New Roman Bold", size: 30)
        button.backgroundColor = UIColor(white: 0.95, alpha: 0.9)
        button.addTarget(self, action: #selector(languageButton1Tapped), for: .touchUpInside)
        button.layer.cornerRadius = 20
        return button
    }()
    
    let listenInputButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let listenImage = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: imageConfig)
        
        button.setImage(listenImage, for: .normal)
        button.tintColor = .white
        button.configuration = .filled()
        button.addTarget(self, action: #selector(listenInputText), for: .touchUpInside)
        return button
    }()
    
    let listenTranslationButton: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        let listenImage = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: imageConfig)
        
        button.setImage(listenImage, for: .normal)
        button.tintColor = .white
        button.configuration = .filled()
        button.addTarget(self, action: #selector(listenTranslationText), for: .touchUpInside)
        return button
    }()
    
    var inputLanguage = "ru"
    var translationLanguage = "en"
    
    var isInputLanguageSelected = false
    var isTranslationLanguageSelected = false
    
    @objc func languageButton1Tapped() {
        showLanguageSelectionAlert(forInputLanguage: true)
    }
    
    @objc func languageButton2Tapped() {
        showLanguageSelectionAlert(forInputLanguage: false)
    }
    
    func showLanguageSelectionAlert(forInputLanguage isInputLanguage: Bool) {
        let alert = UIAlertController(title: "Выберите язык", message: nil, preferredStyle: .actionSheet)
        
        for (languageName, languageCode) in LanguageCodes.languages {
            alert.addAction(UIAlertAction(title: languageName, style: .default) { _ in
                if isInputLanguage {
                    self.inputLanguage = languageCode
                    self.languageButton1.setTitle(languageName, for: .normal)
                } else {
                    self.translationLanguage = languageCode
                    self.languageButton2.setTitle(languageName, for: .normal)
                    self.translateText(sourceText: self.textView1.text, sourceLanguage: self.inputLanguage, targetLanguage: self.translationLanguage) { translation in
                        DispatchQueue.main.async {
                            self.textView2.text = translation
                        }
                    }
                }
                if self.isInputLanguageSelected {
                    self.languageButton1.setTitle(languageName, for: .normal)
                }
                if self.isTranslationLanguageSelected {
                    self.languageButton2.setTitle(languageName, for: .normal)
                }
                self.saveSelectedLanguages()
                self.saveSelectedLanguages()
            })
        }
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func translateText(sourceText: String, sourceLanguage: String, targetLanguage: String, completion: @escaping (String) -> Void) {
        translator.translateText(direction: "\(sourceLanguage)-\(targetLanguage)", text: sourceText) { translation in
            completion(translation)
        }
    }
    
    func saveSelectedLanguages() {
        let defaults = UserDefaults.standard
        defaults.set(inputLanguage, forKey: "InputLanguage")
        defaults.set(translationLanguage, forKey: "TranslationLanguage")
    }
    
    func loadSelectedLanguages() {
        let defaults = UserDefaults.standard
        if let inputLang = defaults.string(forKey: "InputLanguage"),
           let translationLang = defaults.string(forKey: "TranslationLanguage") {
            inputLanguage = inputLang
            translationLanguage = translationLang
        }
        languageButton1.setTitle(LanguageCodes.languages.first { $0.value == inputLanguage }?.key, for: .normal)
        languageButton2.setTitle(LanguageCodes.languages.first { $0.value == translationLanguage }?.key, for: .normal)
    }
    
    @objc func listenInputText() {
        guard let inputText = textView1.text, !inputText.isEmpty else {
            return
        }
        
        let inputUtterance = AVSpeechUtterance(string: inputText)
        speechSynthesizer.speak(inputUtterance)
    }
    
    @objc func listenTranslationText() {
        guard let translationText = textView2.text, !translationText.isEmpty else {
            return
        }
        
        let translationUtterance = AVSpeechUtterance(string: translationText)
        speechSynthesizer.speak(translationUtterance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView1.delegate = self
        setupScene()
        makeConstraints()
        loadSelectedLanguages()
    }
}

extension ViewController {
    
    func setupScene() {
        view.addSubview(textView1)
        view.addSubview(textView2)
        view.addSubview(languageButton1)
        view.addSubview(languageButton2)
        view.addSubview(listenInputButton)
        view.addSubview(listenTranslationButton)
        view.insertSubview(backgroundImage, at: 0)
    }
    func makeConstraints() {
        textView1.snp.makeConstraints() {
            $0.top.equalToSuperview().inset(130)
            $0.right.left.equalToSuperview().inset(50)
            $0.bottom.equalTo(view.snp.centerY).offset(-40)
        }
        
        textView2.snp.makeConstraints() {
            $0.bottom.equalToSuperview().inset(100)
            $0.right.left.equalToSuperview().inset(50)
            $0.top.equalTo(view.snp.centerY).offset(70)
        }
        
        languageButton1.snp.makeConstraints() {
            $0.bottom.equalTo(textView1.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
        }
        
        languageButton2.snp.makeConstraints() {
            $0.bottom.equalTo(textView2.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
        }
        
        listenInputButton.snp.makeConstraints() {
            $0.top.equalTo(textView1.snp.bottom).offset(10)
            $0.right.equalToSuperview().inset(50)
        }
        
        listenTranslationButton.snp.makeConstraints() {
            $0.top.equalTo(textView2.snp.bottom).offset(10)
            $0.right.equalToSuperview().inset(50)
        }
        
        backgroundImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard let sourceText = textView.text else { return }
        var sourceLanguage = self.inputLanguage
        var targetLanguage = self.translationLanguage
        
        if textView == textView2 {
            sourceLanguage = self.translationLanguage
            targetLanguage = self.inputLanguage
        }
        
        translateText(sourceText: sourceText, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage) { translation in
            DispatchQueue.main.async {
                if textView == self.textView1 {
                    self.textView2.text = translation
                } else {
                    self.textView1.text = translation
                }
            }
        }
    }
}

