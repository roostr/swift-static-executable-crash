//import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req -> Response in
        let response = try await req.client.get("https://example.org/")
        return Response(status: response.status, version: .http1_1, headers: .init(), body: .init(buffer: response.body ?? ByteBuffer()))
    }
}
