class AppFormatters {
  static String formatNumber(num value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  static String formatVolume(double liters) {
    if (liters >= 1000000) {
      return '${(liters / 1000000).toStringAsFixed(2)} ML';
    } else if (liters >= 1000) {
      return '${(liters / 1000).toStringAsFixed(2)} KL';
    } else {
      return '${liters.toStringAsFixed(2)} L';
    }
  }

  static String formatFlowRate(double litersPerMinute) {
    return '${litersPerMinute.toStringAsFixed(1)} L/min';
  }

  static String formatTemperature(double celsius) {
    return '${celsius.toStringAsFixed(1)}°C';
  }

  static String formatHumidity(double percent) {
    return '${percent.toStringAsFixed(0)}%';
  }

  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  static String formatEnergy(double kwh) {
    if (kwh >= 1000) {
      return '${(kwh / 1000).toStringAsFixed(2)} MWh';
    }
    return '${kwh.toStringAsFixed(2)} kWh';
  }

  static String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }
}
