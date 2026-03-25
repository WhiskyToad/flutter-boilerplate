import 'package:intl/intl.dart';

enum CompactFormatType {
  /// No compact formatting (e.g., $1,500,000.00).
  none,

  /// Short compact formatting (e.g., $1.5M).
  short,

  /// Long compact formatting (e.g., $1.5 million).
  long,
}

/// A utility class for formatting currency values.
///
/// This class provides methods to format numbers as currency strings,
///

class CurrencyFormatterUtil {
  CurrencyFormatterUtil._();

  /// [amount] can be a [num] or a [String] representation of a number
  /// (e.g., 1234.56).
  /// [locale] specifies the locale to use for formatting
  /// (e.g., 'en_US' for US Dollar).
  /// [currencyCode] overrides the currency code derived from the locale
  /// (e.g., 'EUR').
  /// [decimalDigits] specifies the number of decimal places to show
  /// (e.g., 2 for $10.50).
  /// [shouldShowSymbol] determines if the currency symbol should be displayed
  /// (default is true).
  /// [symbolOverride] allows providing a custom currency symbol (e.g., '₹').
  /// [groupingSeparator] allows customizing the grouping separator
  /// (e.g., ',' -> 1,000).
  /// [decimalSeparator] allows customizing the decimal separator
  /// (e.g., '.' -> 10.50).
  /// [symbolSeparator] allows adding a separator between the symbol and the
  /// amount (e.g., ' ' -> $ 100).
  /// [compactFormatType] specifies the type of compact formatting to apply
  /// (e.g., [CompactFormatType.short] -> $1.2K).
  /// [fallbackValue] is returned if the amount is null or invalid
  /// (default is '0.00').
  static String format(
    dynamic amount, {
    required String locale,
    String? currencyCode,
    int? decimalDigits = 2,
    bool shouldShowSymbol = true,
    String? symbolOverride,
    String? groupingSeparator,
    String? decimalSeparator,
    String? symbolSeparator,
    CompactFormatType compactFormatType = CompactFormatType.none,
    String fallbackValue = '0.00',
  }) {
    if (amount == null) return fallbackValue;

    num? numericAmount;
    if (amount is num) {
      numericAmount = amount;
    } else if (amount is String) {
      numericAmount = num.tryParse(amount);
    }
    if (numericAmount == null) return fallbackValue;

    try {
      final resolvedCurrencyCode =
          currencyCode ?? _getCurrencyCodeForLocale(locale);

      final useCustomFormatting =
          groupingSeparator != null ||
          decimalSeparator != null ||
          symbolSeparator != null;

      if (useCustomFormatting && compactFormatType == CompactFormatType.none) {
        return _formatCustomCurrency(
          numericAmount,
          locale: locale,
          currencyCode: resolvedCurrencyCode,
          decimalDigits: decimalDigits,
          shouldShowSymbol: shouldShowSymbol,
          symbolOverride: symbolOverride,
          groupingSeparator: groupingSeparator,
          decimalSeparator: decimalSeparator,
          symbolSeparator: symbolSeparator,
        );
      }

      final numberFormatter = _createNumberFormatter(
        locale: locale,
        currencyCode: resolvedCurrencyCode,
        decimalDigits: decimalDigits,
        shouldShowSymbol: shouldShowSymbol,
        symbolOverride: symbolOverride,
        compactFormatType: compactFormatType,
      );

      return numberFormatter.format(numericAmount);
    } catch (_) {
      return fallbackValue;
    }
  }

  static String? _getCurrencyCodeForLocale(String locale) {
    try {
      return NumberFormat.simpleCurrency(locale: locale).currencyName;
    } catch (_) {
      return null;
    }
  }

  static String _formatCustomCurrency(
    num amount, {
    required String locale,
    String? currencyCode,
    int? decimalDigits,
    required bool shouldShowSymbol,
    String? symbolOverride,
    String? groupingSeparator,
    String? decimalSeparator,
    String? symbolSeparator,
  }) {
    // Use NumberFormat to get default locale formatting
    final formatter = NumberFormat.currency(
      locale: locale,
      name: currencyCode,
      symbol: shouldShowSymbol
          ? (symbolOverride ??
                NumberFormat.simpleCurrency(
                  locale: locale,
                  name: currencyCode,
                ).currencySymbol)
          : '',
      decimalDigits: decimalDigits,
    );

    String formattedCurrency = formatter.format(amount);

    if (groupingSeparator != null || decimalSeparator != null) {
      final defaultGroupingSeparator = formatter.symbols.GROUP_SEP;
      final defaultDecimalSeparator = formatter.symbols.DECIMAL_SEP;

      // Const placeholders ensure a safe swap of grouping and decimal separators.
      // Direct replacement would turn "$1.234.56" into "$1,234,56"
      // when swapping ',' and '.'.

      // Using these placeholders prevents that conflict.
      const groupingPlaceholder = '##GROUP##';
      const decimalPlaceholder = '##DECIMAL##';

      if (groupingSeparator != null && defaultGroupingSeparator.isNotEmpty) {
        formattedCurrency = formattedCurrency.replaceAll(
          defaultGroupingSeparator,
          groupingPlaceholder,
        );
      }
      if (decimalSeparator != null && defaultDecimalSeparator.isNotEmpty) {
        formattedCurrency = formattedCurrency.replaceAll(
          defaultDecimalSeparator,
          decimalPlaceholder,
        );
      }

      if (groupingSeparator != null && defaultGroupingSeparator.isNotEmpty) {
        formattedCurrency = formattedCurrency.replaceAll(
          groupingPlaceholder,
          groupingSeparator,
        );
      }
      if (decimalSeparator != null && defaultDecimalSeparator.isNotEmpty) {
        formattedCurrency = formattedCurrency.replaceAll(
          decimalPlaceholder,
          decimalSeparator,
        );
      }
    }

    // Add symbol separator if provided
    if (symbolSeparator != null && shouldShowSymbol) {
      final currencySymbol =
          symbolOverride ??
          NumberFormat.simpleCurrency(
            locale: locale,
            name: currencyCode,
          ).currencySymbol;

      if (currencySymbol.isNotEmpty) {
        if (formattedCurrency.trim().startsWith(currencySymbol)) {
          formattedCurrency = formattedCurrency.replaceFirst(
            currencySymbol,
            '$currencySymbol$symbolSeparator',
          );
        } else if (formattedCurrency.trim().endsWith(currencySymbol)) {
          final symbolLastIndex = formattedCurrency.lastIndexOf(currencySymbol);
          formattedCurrency =
              formattedCurrency.substring(0, symbolLastIndex) +
              symbolSeparator +
              formattedCurrency.substring(symbolLastIndex);
        }
      }
    }

    return formattedCurrency;
  }

  static NumberFormat _createNumberFormatter({
    required String locale,
    String? currencyCode,
    int? decimalDigits,
    required bool shouldShowSymbol,
    String? symbolOverride,
    required CompactFormatType compactFormatType,
  }) {
    final resolvedSymbol = shouldShowSymbol
        ? symbolOverride ??
              NumberFormat.simpleCurrency(
                locale: locale,
                name: currencyCode,
              ).currencySymbol
        : '';

    switch (compactFormatType) {
      case CompactFormatType.short:
        return NumberFormat.compactCurrency(
          locale: locale,
          name: currencyCode,
          symbol: resolvedSymbol,
          decimalDigits: decimalDigits,
        );
      case CompactFormatType.long:
        final formatter = NumberFormat.compactLong(locale: locale);
        if (decimalDigits != null) {
          formatter.minimumFractionDigits = decimalDigits;
          formatter.maximumFractionDigits = decimalDigits;
        }
        return formatter;
      case CompactFormatType.none:
        return NumberFormat.currency(
          locale: locale,
          name: currencyCode,
          symbol: resolvedSymbol,
          decimalDigits: decimalDigits,
        );
    }
  }
}
