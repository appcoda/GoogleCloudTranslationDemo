//
//  TranslationManager.swift
//  Translate
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import Foundation


struct TranslationLanguage {
    var code: String?
    var name: String?
}


class TranslationManager: NSObject {
    
    // MARK: - Properties
    
    static let shared = TranslationManager()
    
    private let apiKey = "YOUR-API-KEY"
    
    var sourceLanguageCode: String?
    
    var supportedLanguages = [TranslationLanguage]()
    
    var textToTranslate: String?
    
    var targetLanguageCode: String?
    
    
    // MARK: - Init
    
    override init() {
        super.init()
    }
    
    
    // MARK: - Private Methods
    
    private func makeRequest(usingTranslationAPI api: TranslationAPI, urlParams: [String: String], completion: @escaping (_ results: [String: Any]?) -> Void) {
        if var components = URLComponents(string: api.getURL()) {
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in urlParams {
                components.queryItems?.append(URLQueryItem(name: key, value: value))
            }
            
            
            if let url = components.url {
                var request = URLRequest(url: url)
                request.httpMethod = api.getHTTPMethod()
                
                
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: request) { (results, response, error) in
                    
                    if let error = error {
                        print(error)
                        completion(nil)
                    } else {
                        if let response = response as? HTTPURLResponse, let results = results {
                            if response.statusCode == 200 || response.statusCode == 201 {
                                do {
                                    if let resultsDict = try JSONSerialization.jsonObject(with: results, options: JSONSerialization.ReadingOptions.mutableLeaves) as? [String: Any] {
                                        completion(resultsDict)
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        } else {
                            completion(nil)
                        }
                    }
                
                }
                
                task.resume()
            }
        }
    }
    
    
    
    // MARK: - Public Methods
    
    func detectLanguage(forText text: String, completion: @escaping (_ language: String?) -> Void) {
        let urlParams = ["key": apiKey, "q": text]
        
        makeRequest(usingTranslationAPI: .detectLanguage, urlParams: urlParams) { (results) in
            guard let results = results else { completion(nil); return }
            
            if let data = results["data"] as? [String: Any], let detections = data["detections"] as? [[[String: Any]]] {
                var detectedLanguages = [String]()
                
                for detection in detections {
                    for currentDetection in detection {
                        if let language = currentDetection["language"] as? String {
                            detectedLanguages.append(language)
                        }
                    }
                }
                
                if detectedLanguages.count > 0 {
                    self.sourceLanguageCode = detectedLanguages[0]
                    completion(detectedLanguages[0])
                } else {
                    completion(nil)
                }
                
            } else {
                completion(nil)
            }
        }
    }
    
    
    func fetchSupportedLanguages(completion: @escaping (_ success: Bool) -> Void) {
        var urlParams = [String: String]()
        urlParams["key"] = apiKey
        urlParams["target"] = Locale.current.languageCode ?? "en"
        
        makeRequest(usingTranslationAPI: .supportedLanguages, urlParams: urlParams) { (results) in
            guard let results = results else { completion(false); return }
            
            if let data = results["data"] as? [String: Any], let languages = data["languages"] as? [[String: Any]] {
                
                for lang in languages {
                    var languageCode: String?
                    var languageName: String?
                    
                    if let code = lang["language"] as? String {
                        languageCode = code
                    }
                    if let name = lang["name"] as? String {
                        languageName = name
                    }
                    
                    self.supportedLanguages.append(TranslationLanguage(code: languageCode, name: languageName))
                }
                
                completion(true)
                
            } else {
                completion(false)
            }
            
        }
    }
    
    
    func translate(completion: @escaping (_ translations: String?) -> Void) {
        guard let textToTranslate = textToTranslate, let targetLanguage = targetLanguageCode else { completion(nil); return }
        
        var urlParams = [String: String]()
        urlParams["key"] = apiKey
        urlParams["q"] = textToTranslate
        urlParams["target"] = targetLanguage
        urlParams["format"] = "text"
        
        if let sourceLanguage = sourceLanguageCode {
            urlParams["source"] = sourceLanguage
        }
        
        
        makeRequest(usingTranslationAPI: .translate, urlParams: urlParams) { (results) in
            guard let results = results else { completion(nil); return }
            
            if let data = results["data"] as? [String: Any], let translations = data["translations"] as? [[String: Any]] {
                var allTranslations = [String]()
                for translation in translations {
                    if let translatedText = translation["translatedText"] as? String {
                        allTranslations.append(translatedText)
                    }
                }
                
                if allTranslations.count > 0 {
                    completion(allTranslations[0])
                } else {
                    completion(nil)
                }
                
                
            } else {
                completion(nil)
            }
        }
    }
}
