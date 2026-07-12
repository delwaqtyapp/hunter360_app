import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('it'),
    Locale('fr'),
    Locale('pt'),
    Locale('de'),
    Locale('tr'),
    Locale('pl'),
    Locale('ru'),
    Locale('cs'),
    Locale('ja'),
    Locale('zh'),
  ];

  String get appName {
    switch (locale.languageCode) {
      case 'ar': return 'هنتر 360';
      case 'en': return 'Hunter 360';
      case 'es': return 'Hunter 360';
      case 'it': return 'Hunter 360';
      case 'fr': return 'Hunter 360';
      case 'pt': return 'Hunter 360';
      case 'de': return 'Hunter 360';
      case 'tr': return 'Hunter 360';
      case 'pl': return 'Hunter 360';
      case 'ru': return 'Hunter 360';
      case 'cs': return 'Hunter 360';
      case 'ja': return 'ハンター360';
      case 'zh': return 'Hunter 360';
      default: return 'Hunter 360';
    }
  }

  String get login {
    switch (locale.languageCode) {
      case 'ar': return 'تسجيل الدخول';
      case 'en': return 'Login';
      case 'es': return 'Iniciar sesión';
      case 'it': return 'Accedi';
      case 'fr': return 'Connexion';
      case 'pt': return 'Entrar';
      case 'de': return 'Anmelden';
      case 'tr': return 'Giriş yap';
      case 'pl': return 'Zaloguj się';
      case 'ru': return 'Войти';
      case 'cs': return 'Přihlásit se';
      case 'ja': return 'ログイン';
      case 'zh': return '登录';
      default: return 'Login';
    }
  }

  String get password {
    switch (locale.languageCode) {
      case 'ar': return 'كلمة المرور';
      case 'en': return 'Password';
      default: return 'Password';
    }
  }

  String get email {
    switch (locale.languageCode) {
      case 'ar': return 'البريد الإلكتروني';
      case 'en': return 'Email';
      default: return 'Email';
    }
  }

  String get dashboard {
    switch (locale.languageCode) {
      case 'ar': return 'لوحة التحكم';
      case 'en': return 'Dashboard';
      default: return 'Dashboard';
    }
  }

  String get controllers {
    switch (locale.languageCode) {
      case 'ar': return 'وحدات التحكم';
      case 'en': return 'Controllers';
      default: return 'Controllers';
    }
  }

  String get schedules {
    switch (locale.languageCode) {
      case 'ar': return 'جداول الري';
      case 'en': return 'Schedules';
      default: return 'Schedules';
    }
  }

  String get alarms {
    switch (locale.languageCode) {
      case 'ar': return 'الإنذارات';
      case 'en': return 'Alarms';
      default: return 'Alarms';
    }
  }

  String get settings {
    switch (locale.languageCode) {
      case 'ar': return 'الإعدادات';
      case 'en': return 'Settings';
      default: return 'Settings';
    }
  }

  String get map {
    switch (locale.languageCode) {
      case 'ar': return 'الخريطة';
      case 'en': return 'Map';
      default: return 'Map';
    }
  }

  String get weather {
    switch (locale.languageCode) {
      case 'ar': return 'الطقس';
      case 'en': return 'Weather';
      default: return 'Weather';
    }
  }

  String get flowManagement {
    switch (locale.languageCode) {
      case 'ar': return 'إدارة التدفق';
      case 'en': return 'Flow Management';
      default: return 'Flow Management';
    }
  }

  String get reports {
    switch (locale.languageCode) {
      case 'ar': return 'التقارير';
      case 'en': return 'Reports';
      default: return 'Reports';
    }
  }

  String get logout {
    switch (locale.languageCode) {
      case 'ar': return 'تسجيل الخروج';
      case 'en': return 'Logout';
      default: return 'Logout';
    }
  }

  String get online {
    switch (locale.languageCode) {
      case 'ar': return 'متصل';
      case 'en': return 'Online';
      default: return 'Online';
    }
  }

  String get offline {
    switch (locale.languageCode) {
      case 'ar': return 'غير متصل';
      case 'en': return 'Offline';
      default: return 'Offline';
    }
  }

  String get manualOperation {
    switch (locale.languageCode) {
      case 'ar': return 'التشغيل اليدوي';
      case 'en': return 'Manual Operation';
      default: return 'Manual Operation';
    }
  }

  String get start {
    switch (locale.languageCode) {
      case 'ar': return 'تشغيل';
      case 'en': return 'Start';
      default: return 'Start';
    }
  }

  String get stop {
    switch (locale.languageCode) {
      case 'ar': return 'إيقاف';
      case 'en': return 'Stop';
      default: return 'Stop';
    }
  }

  String get save {
    switch (locale.languageCode) {
      case 'ar': return 'حفظ';
      case 'en': return 'Save';
      default: return 'Save';
    }
  }

  String get cancel {
    switch (locale.languageCode) {
      case 'ar': return 'إلغاء';
      case 'en': return 'Cancel';
      default: return 'Cancel';
    }
  }

  String get confirm {
    switch (locale.languageCode) {
      case 'ar': return 'تأكيد';
      case 'en': return 'Confirm';
      default: return 'Confirm';
    }
  }

  String get noData {
    switch (locale.languageCode) {
      case 'ar': return 'لا توجد بيانات';
      case 'en': return 'No data available';
      default: return 'No data available';
    }
  }

  String get loading {
    switch (locale.languageCode) {
      case 'ar': return 'جاري التحميل...';
      case 'en': return 'Loading...';
      default: return 'Loading...';
    }
  }

  String get error {
    switch (locale.languageCode) {
      case 'ar': return 'خطأ';
      case 'en': return 'Error';
      default: return 'Error';
    }
  }

  String get retry {
    switch (locale.languageCode) {
      case 'ar': return 'إعادة المحاولة';
      case 'en': return 'Retry';
      default: return 'Retry';
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en', 'es', 'it', 'fr', 'pt', 'de', 'tr', 'pl', 'ru', 'cs', 'ja', 'zh']
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
