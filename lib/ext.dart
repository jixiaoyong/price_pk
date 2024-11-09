/// @author : jixiaoyong
/// @description ：数字转换为带千分位的货币格式
///
/// @email : jixiaoyong1995@gmail.com
/// @date : 9/11/2024
extension DoubleToCurrencyExtension on double {
  String toCurrencyString({int decimalPlaces = 2}) {
    // 检查decimalPlaces是否为非负数
    if (decimalPlaces < 0) {
      throw ArgumentError('decimalPlaces must be non-negative');
    }

    // 将数字转换为字符串，并使用substring截取小数部分
    String formattedAmount = toStringAsFixed(decimalPlaces);

    // 添加千分位分隔符
    var parts = formattedAmount.split('.');
    parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+$)'), (Match m) => '${m[1]},');

    return parts.join('.'); // 使用¥作为货币符号，可以根据需要替换
  }
}
