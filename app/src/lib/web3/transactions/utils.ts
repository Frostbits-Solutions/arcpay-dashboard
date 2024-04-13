export function longToByteArray (long: number) {
  const byteArray = [0, 0, 0, 0, 0, 0, 0, 0]

  for (let index = byteArray.length - 1; index >= 0; index--) {
    const byte = long & 0xff
    byteArray[index] = byte
    long = (long - byte) / 256
  }

  return new Uint8Array(byteArray)
}

export function base64ToArrayBuffer (base64: string) {
  const binaryString = window.atob(base64)
  const len = binaryString.length
  const bytes = new Uint8Array(len)
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i)
  }
  return bytes
}
