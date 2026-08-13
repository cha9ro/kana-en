#!/usr/bin/env swift

import AppKit

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: generate-icon.swift OUTPUT.iconset\n", stderr)
    exit(2)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let variants: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func makeIcon(pixels: Int) throws -> Data {
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    bitmap.size = NSSize(width: pixels, height: pixels)
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        throw CocoaError(.fileWriteUnknown)
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let canvas = NSRect(x: 0, y: 0, width: pixels, height: pixels)
    NSColor.clear.setFill()
    canvas.fill()

    // The menu bar uses this same SF Symbol. A blue tile keeps the static app
    // icon legible in both the light and dark Finder appearances.
    let inset = CGFloat(pixels) * 0.08
    let tile = canvas.insetBy(dx: inset, dy: inset)
    let tilePath = NSBezierPath(
        roundedRect: tile,
        xRadius: CGFloat(pixels) * 0.21,
        yRadius: CGFloat(pixels) * 0.21
    )
    let gradient = NSGradient(
        starting: NSColor(calibratedRed: 0.30, green: 0.68, blue: 1.00, alpha: 1),
        ending: NSColor(calibratedRed: 0.03, green: 0.38, blue: 0.94, alpha: 1)
    )!
    gradient.draw(in: tilePath, angle: -90)

    let pointSize = CGFloat(pixels) * 0.46
    let configuration = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
        .applying(.init(paletteColors: [.white]))
    guard let symbol = NSImage(systemSymbolName: "character.cursor.ibeam", accessibilityDescription: "KanaEn")?
        .withSymbolConfiguration(configuration) else {
        throw CocoaError(.featureUnsupported)
    }

    let symbolSize = symbol.size
    let symbolRect = NSRect(
        x: canvas.midX - symbolSize.width / 2,
        y: canvas.midY - symbolSize.height / 2,
        width: symbolSize.width,
        height: symbolSize.height
    )
    symbol.draw(in: symbolRect)

    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    return png
}

for variant in variants {
    let data = try makeIcon(pixels: variant.pixels)
    try data.write(to: outputDirectory.appendingPathComponent(variant.name), options: .atomic)
}
