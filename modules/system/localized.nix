{ lib, config, ...}:

{
  ## 时区
  time.timeZone = "Asia/Shanghai";

  # 编码 Locale
  i18n = {

    defaultLocale = "en_US.UTF-8";

    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };
}
