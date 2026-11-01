import Foundation
import SwiftUI

/// Output-kind chips for the cloud files explorers.
///
/// `ZeusCloudFilesView` filters its grid by kind, and the artifacts sheet
/// (`ZeusConversationFiles`) presents the same classification. The previous
/// integration referenced this type without shipping it, which failed both
/// the device build and the integration test bundle.
enum ZeusOutputKind: String, CaseIterable, Hashable {
    case image
    case video
    case audio
    case code
    case archive
    case document
    case data
    case other

    var title: String {
        switch self {
        case .image: return "صور"
        case .video: return "فيديو"
        case .audio: return "صوت"
        case .code: return "كود"
        case .archive: return "أرشيف"
        case .document: return "مستندات"
        case .data: return "بيانات"
        case .other: return "أخرى"
        }
    }

    var symbol: String {
        switch self {
        case .image: return "photo"
        case .video: return "film"
        case .audio: return "waveform"
        case .code: return "curlybraces.square"
        case .archive: return "archivebox"
        case .document: return "doc.richtext"
        case .data: return "tablecells"
        case .other: return "doc"
        }
    }

    static func classify(_ url: URL) -> ZeusOutputKind {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "png", "jpg", "jpeg", "gif", "webp", "heic", "heif", "bmp", "tiff", "svg", "ico":
            return .image
        case "mp4", "mov", "m4v", "webm", "avi", "mkv":
            return .video
        case "mp3", "m4a", "aac", "wav", "ogg", "flac", "opus":
            return .audio
        case "swift", "py", "js", "ts", "tsx", "jsx", "m", "mm", "h", "hpp", "c", "cpp", "go",
             "rs", "java", "kt", "rb", "php", "sh", "bash", "zsh", "sql", "r", "lua", "dart",
             "css", "scss", "html", "xml", "yaml", "yml", "toml":
            return .code
        case "zip", "ipa", "apk", "tar", "gz", "bz2", "xz", "7z", "rar", "tgz", "dmg":
            return .archive
        case "pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "rtf", "odt", "md", "epub":
            return .document
        case "json", "csv", "tsv", "plist", "db", "sqlite", "sqlite3", "log", "jsonl", "ndjson",
             "env", "ini", "cfg", "conf":
            return .data
        default:
            return .other
        }
    }
}

/// Artifacts sheet for one chat session: the files that session produced.
///
/// `native_ui.py` wires `ZeusConversationFiles(sessionID: vm.sessionId)` into
/// `AIChatView`, and `NativePersonalizationTests` hosts the same view. The
/// integration imported the name without shipping the view, so both the
/// device build and the test bundle were red.
struct ZeusConversationFiles: View {
    let sessionID: String

    var body: some View {
        ZeusCloudFilesView(session: sessionID, folders: false)
    }
}
