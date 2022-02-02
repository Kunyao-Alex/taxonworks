export default function selectFirstSmartOption (lists, keys) {
  return keys.find(key => lists[key] && (lists[key].length > 0)) || keys[0]
}
