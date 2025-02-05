import Foundation
import PencilKit

class OpenAIService {
    private let apiKey = APIConfig.openAIKey
    private let baseURL = "https://api.openai.com"
    
    func analyzeAndGenerateImage(from drawing: PKDrawing) async throws -> PKDrawing {
        // 1. Convert drawing to base64
        let uiImage = drawing.image(from: drawing.bounds, scale: 1)
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 1)
        }
        let base64Image = imageData.base64EncodedString()
        
        // 2. Send to Vision API for analysis
        let analysisResponse = try await analyzeImage(base64Image)
        
        // 3. Generate new image based on analysis
        let generatedImageURL = try await generateImage(from: analysisResponse)
        
        // 4. Download and convert the generated image
        let (data, _) = try await URLSession.shared.data(from: generatedImageURL)
        guard let generatedUIImage = UIImage(data: data) else {
            throw NSError(domain: "ImageConversion", code: 2)
        }
        
        // Convert UIImage to Data
        guard let imageData = generatedUIImage.pngData() else {
            throw NSError(domain: "ImageConversion", code: 3)
        }
        
        // Create a new drawing from the image data
        return try PKDrawing(data: imageData)
    }
    
    private func analyzeImage(_ base64Image: String) async throws -> String {
        let endpoint = "\(baseURL)/v1/chat/completions"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this drawing and describe its composition, style, and key features. Identify the image type (e.g., 'simple diagram', 'detailed illustration', 'technical drawing', or 'sketch').If the image consists of basic geometric shapes, classify it as a diagram and describe the structure precisely. If the image has rough, organic strokes that suggest artistic intent, classify it as a sketch and describe its artistic qualities. Identify any recognizable objects in the image, specifying their type. For example, if it is a vehicle, determine whether it is a 'sports car', 'SUV', 'classic car', 'truck', or another type based on its shape. For vehicles, ensure that the AI preserves the original category—a sports car should remain a sports car, an SUV should remain an SUV, etc. Apply this level of analysis to all objects in the image, ensuring their core characteristics are maintained in the final output."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        // Add debug print
        if let httpResponse = httpResponse as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            
            // Handle error response
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "OpenAI",
                            code: httpResponse.statusCode,
                            userInfo: [NSLocalizedDescriptionKey: "API request failed with status code \(httpResponse.statusCode)"])
            }
        }
        
        let decodedResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return decodedResponse.choices.first?.message.content ?? ""
    }
    
    private func generateImage(from description: String) async throws -> URL {
        let endpoint = "\(baseURL)/v1/images/generations"
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = "Generate an improved version of the image based on the following description: \(description). If the sketch is simplistic or cartoonish, preserve that style—do not make it more complex or technical. Refine the shapes without drastically altering proportions. Do not introduce additional technical details unless explicitly mentioned. If the image consists of simple geometric forms, preserve their proportions and angles exactly. If the drawing is a simple object (e.g., a car, house, airplane), strictly preserve the shape and proportions without exaggeration. If the object is a vehicle, maintain the original design language—if it looks like a modern sports car, refine it into a sleek, aerodynamic sports car, not a vintage vehicle. Do not add artistic re-interpretations unless specified."
        let payload: [String: Any] = [
            "model": "dall-e-3",
            "prompt": prompt,
            "n": 1,
            "quality": "standard",
            "size": "1024x1024"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        // Add debug print
        if let httpResponse = httpResponse as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        
        let decodedResponse = try JSONDecoder().decode(DALLEResponse.self, from: data)
        return URL(string: decodedResponse.data.first?.url ?? "")!
    }
    
    func generateImageFromDrawing(_ drawing: PKDrawing, onAnalysisComplete: @escaping () -> Void) async throws -> (UIImage, String) {
        // 1. Convert drawing to base64
        let uiImage = drawing.image(from: drawing.bounds, scale: 1)
        guard let imageData = uiImage.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConversion", code: 1)
        }
        let base64Image = imageData.base64EncodedString()
        
        // 2. Send to Vision API for analysis
        let analysisResponse = try await analyzeImage(base64Image)
        
        // Signal that analysis is complete
        await MainActor.run {
            onAnalysisComplete()
        }
        
        // 3. Generate new image based on analysis
        let generatedImageURL = try await generateImage(from: analysisResponse)
        
        // 4. Download the generated image
        let (data, _) = try await URLSession.shared.data(from: generatedImageURL)
        guard let generatedUIImage = UIImage(data: data) else {
            throw NSError(domain: "ImageConversion", code: 2)
        }
        
        return (generatedUIImage, analysisResponse)
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct DALLEResponse: Codable {
    let data: [ImageData]
    
    struct ImageData: Codable {
        let url: String
    }
} 