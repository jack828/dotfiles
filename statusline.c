#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "time.h"
#include <ctype.h>
#include <sys/stat.h>

#define AC_STATUS_FILE "/sys/class/power_supply/AC/online"
#define BATTERY_LEVEL_FILE "/sys/class/power_supply/BAT0/capacity"
#define CPU_TEMP_FILE "/sys/class/hwmon/hwmon1/temp1_input"
#define LOAD_AVG_FILE "/proc/loadavg"
#define MEMORY_INFO_FILE "/proc/meminfo"
#define FAN_STATUS_FILE "/proc/acpi/ibm/fan"
#define WIREGUARD_INTERFACE_FILE "/proc/net/dev_snmp6/wg0"

void stripNonDigits(char *input, int length) {
  char *output = malloc(length);
  int index = 0;
  char *sPtr = input;

  for (; *sPtr != '\0'; sPtr++) {
    if (isdigit(*sPtr)) {
      output[index++] = *sPtr;
    }
  }

  strcpy(input, output);
}

void resetStyles() { fputs("#[default]", stdout); }

int main() {
  /* Power */
  fputs("#[bg=colour236]", stdout);

  FILE *acStatusFile = fopen(AC_STATUS_FILE, "r");
  char acStatus = fgetc(acStatusFile);
  fclose(acStatusFile);

  if (acStatus == '1') {
    fputs("#[fg=colour118,bold] AC ⌁ #[default]", stdout);
  } else {
    FILE *batteryLevelFile = fopen(BATTERY_LEVEL_FILE, "r");

    char batteryLevelString[4];
    fgets(batteryLevelString, 4, batteryLevelFile);
    fclose(batteryLevelFile);

    int batteryLevel = atoi(batteryLevelString);

    if (batteryLevel > 75) {
      /* Green */
      fputs("#[fg=colour118]", stdout);
    } else if (batteryLevel > 50) {
      /* Orange */
      fputs("#[fg=colour214]", stdout);
    } else {
      /* Red */
      fputs("#[fg=colour196,reverse]", stdout);
    }
    fprintf(stdout, " %2d %% ", batteryLevel);
    resetStyles();
  }

  /* CPU Temp */
  FILE *cpuTempFile = fopen(CPU_TEMP_FILE, "r");
  char cpuTempString[3];
  fgets(cpuTempString, 3, cpuTempFile);
  fclose(cpuTempFile);

  int cpuTemp = atoi(cpuTempString);

  fputs("#[bg=colour237]", stdout);
  if (cpuTemp > 80) {
    /* Red */
    fputs("#[fg=colour196,reverse]", stdout);
  } else if (cpuTemp > 50) {
    /* Orange */
    fputs("#[fg=colour214]", stdout);
  } else {
    /* Green */
    fputs("#[fg=colour118]", stdout);
  }
  fprintf(stdout, " %d°C ", cpuTemp);
  resetStyles();

  /* Load Avg */
  FILE *loadAvgFile = fopen(LOAD_AVG_FILE, "r");
  char loadAvg[5];
  fgets(loadAvg, 5, loadAvgFile);
  fclose(loadAvgFile);

  fprintf(stdout, "#[fg=colour231,bg=colour236] %s ", loadAvg);

  /* Memory Usage */
  FILE *memoryFile = fopen(MEMORY_INFO_FILE, "r");
  char *memoryTotalLine = NULL;
  char *memoryFreeLine = NULL;
  char *memoryAvailableLine = NULL;
  size_t size = 0;
  getline(&memoryTotalLine, &size, memoryFile);
  /* We don't actually care about this one, but it's next */
  getline(&memoryFreeLine, &size, memoryFile);
  getline(&memoryAvailableLine, &size, memoryFile);
  fclose(memoryFile);

  stripNonDigits(memoryTotalLine, strlen(memoryTotalLine));
  stripNonDigits(memoryAvailableLine, strlen(memoryAvailableLine));

  double memoryTotal = strtod(memoryTotalLine, NULL);
  double memoryAvailable = strtod(memoryAvailableLine, NULL);
  double freeMemoryPercentage = (memoryAvailable / memoryTotal) * 100;
  double usedMemoryPercentage = 100 - freeMemoryPercentage;

  fputs("#[bg=colour237]", stdout);
  if (usedMemoryPercentage > 75) {
    /* Red */
    fputs("#[fg=colour196,reverse]", stdout);
  } else if (usedMemoryPercentage > 50) {
    /* Orange */
    fputs("#[fg=colour214]", stdout);
  } else {
    /* Green */
    fputs("#[fg=colour118]", stdout);
  }
  fprintf(stdout, " %2.f%% ", usedMemoryPercentage);
  resetStyles();

  /* Fan Speed */
  FILE *fanFile = fopen(FAN_STATUS_FILE, "r");
  char *fanStatusLine = NULL;
  char *fanSpeedLine = NULL;
  /* We don't actually care about this one, but it's first */
  getline(&fanStatusLine, &size, fanFile);
  getline(&fanSpeedLine, &size, fanFile);
  fclose(fanFile);

  stripNonDigits(fanSpeedLine, strlen(fanSpeedLine));
  int fanSpeed = atoi(fanSpeedLine);

  fprintf(stdout, "#[fg=colour231,bg=colour236] %4d ", fanSpeed);

  /* VPN Status */
  fputs("#[bg=colour237,bold]", stdout);

  struct stat buffer;
  int exists = stat(WIREGUARD_INTERFACE_FILE, &buffer);
  if (exists == 0) {
    fputs("#[fg=colour118] VPN ↑ ", stdout);
  } else {
    fputs("#[fg=colour196] VPN ↓ ", stdout);
  }
  resetStyles();

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

  fprintf(stdout,
          "#[fg=colour146,bold,bg=colour237] %s "
          "#[fg=colour176,bold,bg=colour236]%s, "
          "#[fg=colour173,bold,bg=colour236]%s#[fg=default] ",
          day, month, year);

  /* Time 24HR */
  char time[6];
  strftime(time, sizeof(time), "%R", info);

  fprintf(stdout, "#[fg=colour234,bold,bg=colour12] %s ", time);

  return 0;
}
