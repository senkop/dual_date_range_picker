import 'package:flutter/foundation.dart';

/// All text shown by the picker. Use [DualPickerLabels.english],
/// [DualPickerLabels.arabic], or create your own.
@immutable
class DualPickerLabels {
  /// Creates a set of labels. Every field defaults to English.
  const DualPickerLabels({
    this.title = 'Select date range',
    this.gregorian = 'Gregorian',
    this.hijri = 'Hijri',
    this.startTime = 'Start Time',
    this.endTime = 'End Time',
    this.cancel = 'Cancel',
    this.apply = 'Apply',
    this.am = 'AM',
    this.pm = 'PM',
    this.invalidRange = 'End must be after start',
    this.today = 'Today',
    this.yesterday = 'Yesterday',
    this.last7Days = 'Last 7 Days',
    this.last30Days = 'Last 30 Days',
    this.weekdaysShort = const ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
    this.weekdaysAbbr = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.gregorianMonths = const [
      'January', 'February', 'March', 'April', 'May', 'June', //
      'July', 'August', 'September', 'October', 'November', 'December',
    ],
    this.hijriMonths = const [
      'Muharram', 'Safar', "Rabi' Al-Awwal", "Rabi' Al-Thani", //
      'Jumada Al-Awwal', 'Jumada Al-Thani', 'Rajab', "Sha'ban",
      'Ramadan', 'Shawwal', "Dhu Al-Qi'dah", 'Dhu Al-Hijjah',
    ],
  });

  /// English labels.
  static const DualPickerLabels english = DualPickerLabels();

  /// Arabic labels. Wrap the dialog in `Directionality(textDirection:
  /// TextDirection.rtl)` (or use an Arabic locale) for right-to-left layout.
  static const DualPickerLabels arabic = DualPickerLabels(
    title: 'اختر الفترة',
    gregorian: 'ميلادي',
    hijri: 'هجري',
    startTime: 'وقت البداية',
    endTime: 'وقت النهاية',
    cancel: 'إلغاء',
    apply: 'تطبيق',
    am: 'ص',
    pm: 'م',
    invalidRange: 'يجب أن تكون النهاية بعد البداية',
    today: 'اليوم',
    yesterday: 'أمس',
    last7Days: 'آخر 7 أيام',
    last30Days: 'آخر 30 يومًا',
    weekdaysShort: ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'],
    weekdaysAbbr: [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', //
      'السبت',
    ],
    gregorianMonths: [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', //
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ],
    hijriMonths: [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', //
      'جمادى الآخرة', 'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة',
      'ذو الحجة',
    ],
  );

  /// Dialog title.
  final String title;

  /// Label of the Gregorian toggle.
  final String gregorian;

  /// Label of the Hijri toggle.
  final String hijri;

  /// Label above the start time field.
  final String startTime;

  /// Label above the end time field.
  final String endTime;

  /// Cancel button.
  final String cancel;

  /// Apply button.
  final String apply;

  /// Morning period.
  final String am;

  /// Afternoon period.
  final String pm;

  /// Shown when the end is before the start.
  final String invalidRange;

  /// Preset: today.
  final String today;

  /// Preset: yesterday.
  final String yesterday;

  /// Preset: last 7 days.
  final String last7Days;

  /// Preset: last 30 days.
  final String last30Days;

  /// One-letter weekday headers, Sunday first.
  final List<String> weekdaysShort;

  /// Weekday names used in the summary line, Sunday first.
  final List<String> weekdaysAbbr;

  /// Gregorian month names, January first.
  final List<String> gregorianMonths;

  /// Hijri month names, Muharram first.
  final List<String> hijriMonths;
}
