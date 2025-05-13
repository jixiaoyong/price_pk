window.copyImageToClipboard = async function(pngBytes) {
  // pngBytes: Uint8List from Dart, passed as JS Uint8Array
  const blob = new Blob([pngBytes], {type: 'image/png'});
  const item = new ClipboardItem({'image/png': blob});
  await navigator.clipboard.write([item]);
}; 