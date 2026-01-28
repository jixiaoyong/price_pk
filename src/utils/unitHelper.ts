/**
 * 移除单位标签中的括号及其内容
 * @param label - 原始单位标签，例如 "克 (g)" 或 "千克 (kg)"
 * @returns 处理后的标签，例如 "克" 或 "千克"
 * 
 * @example
 * removeUnitBrackets('克 (g)') // => '克'
 * removeUnitBrackets('斤 (500g)') // => '斤'
 * removeUnitBrackets('个/件') // => '个/件' (无括号的保持不变)
 */
export function removeUnitBrackets(label: string): string {
    // 使用正则表达式去除括号及其内容，并修剪前后空白
    return label.replace(/\s*\(.*?\)\s*/g, '').trim();
}
