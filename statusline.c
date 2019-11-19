#include "stdio.h"
#include <sys/stat.h>
#include "time.h"

int main () {
  /* Power */
  fputs("#[fg=colour231,bg=colour236] ", stdout);

  FILE* acOnlineFile = fopen("/sys/class/power_supply/AC/online", "r");
  char acOnline = fgetc(acOnlineFile);
  fclose(acOnlineFile);

  if (acOnline == '1') {
    fputs("#[fg=colour118,bold]AC ⌁ ", stdout);
  } else {
    FILE* batteryLevelFile = fopen("/sys/class/power_supply/BAT0/capacity", "r");
    char batteryLevel[3];
    fgets(batteryLevel, 3, batteryLevelFile);
    fclose(batteryLevelFile);

    fprintf(stdout, "%3s%% ", batteryLevel);
  }

  /* CPU Temp */
  FILE* cpuTempFile = fopen("/sys/class/hwmon/hwmon1/temp1_input", "r");
  char cpuTemp[3];
  fgets(cpuTemp, 3, cpuTempFile);
  fclose(cpuTempFile);

  fprintf(stdout, "#[fg=colour231,bg=colour237] %s°C ", cpuTemp);

  /* Load Avg */
  FILE* loadAvgFile = fopen("/proc/loadavg", "r");
  char loadAvg[5];
  fgets(loadAvg, 5, loadAvgFile);
  fclose(loadAvgFile);

  fprintf(stdout, "#[fg=colour231,bg=colour236] %s ", loadAvg);

  /* Fan Speed */

  /* VPN Status */
  fputs("#[fg=colour231,bg=colour237]", stdout);

  struct stat buffer;
  int exists = stat("/proc/net/dev_snmp6/wg0", &buffer);
  if (exists == 0) {
    fputs("#[fg=colour118,bold] VPN ↑ ", stdout);
  } else {
    fputs("#[fg=colour196,bold] VPN ↓ ", stdout);
  }

  /* Day Month, Year */
  char day[3];
  char month[10];
  char year[5];
  time_t rawtime;
  struct tm *info;

  time(&rawtime);
  info = localtime(&rawtime);

  strftime(day, sizeof(day), "%d", info);
  strftime(month, sizeof(month), "%B", info);
  strftime(year, sizeof(year), "%Y", info);

  fprintf(
    stdout,
    "#[fg=colour146,bold,bg=colour236] %s #[fg=colour176,bold,bg=colour236]%s, #[fg=colour173,bold,bg=colour236]%s#[fg=default] ",
    day,
    month,
    year
  );

  /* Time 24HR */
  char time[6];
  strftime(time, sizeof(time), "%R", info);

  fprintf(stdout, "#[fg=colour234,bold,bg=colour12] %s ", time);

  return 0;
}
