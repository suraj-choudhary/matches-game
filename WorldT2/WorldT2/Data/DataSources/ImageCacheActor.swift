import Foundation

/// Actor-isolated asynchronous image byte cache using Swift Structured Concurrency.
public actor ImageCacheActor {
    public static let shared = ImageCacheActor()

    private var cache: [URL: Data] = [:]
    private var inFlightTasks: [URL: Task<Data, Error>] = [:]

    public init() {}

    public func imageData(for url: URL) async throws -> Data {
        if let cached = cache[url] {
            return cached
        }
        if let existingTask = inFlightTasks[url] {
            return try await existingTask.value
        }

        let task = Task<Data, Error> {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse,
                  (200...299).contains(http.statusCode),
                  !data.isEmpty else {
                throw URLError(.cannotDecodeRawData)
            }
            return data
        }

        inFlightTasks[url] = task
        do {
            let data = try await task.value
            cache[url] = data
            inFlightTasks[url] = nil
            return data
        } catch {
            inFlightTasks[url] = nil
            throw error
        }
    }
}
