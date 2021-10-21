#include <ctype.h>
#include <linux/wireless.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <time.h>

#define AC_STATUS_FILE "/sys/class/power_supply/AC/online"
#define BATTERY_LEVEL_FILE "/sys/class/power_supply/BAT0/capacity"
#define CPU_TEMP_FILE "/sys/class/hwmon/hwmon1/temp1_input"
#define LOAD_AVG_FILE "/proc/loadavg"
#define MEMORY_INFO_FILE "/proc/meminfo"
#define FAN_STATUS_FILE "/proc/acpi/ibm/fan"
#define WIREGUARD_INTERFACE_FILE "/proc/net/dev_snmp6/wg0"
#define ETHERNET_INTERFACE "enp0s31f6"
#define WIRELESS_INTERFACE "wlp3s0"
#define WIRELESS_FILE "/proc/net/wireless"

// Not actually my location, but close enough
#define LAT 55.116889
#define LNG -4.436861

// Trigonometry for sun position calculations
#define PI 3.1415926535897932384
#define RADEG (180.0 / PI)
#define DEGRAD (PI / 180.0)
#define sind(x) sin((x)*DEGRAD)
#define cosd(x) cos((x)*DEGRAD)
#define tand(x) tan((x)*DEGRAD)
#define atand(x) (RADEG * atan(x))
#define asind(x) (RADEG * asin(x))
#define acosd(x) (RADEG * acos(x))
#define atan2d(y, x) (RADEG * atan2(y, x))

// COLOURS https://jonasjacek.github.io/colors/
#define RED "colour196"      // #FF0000
#define ORANGE "colour214"   // #FFAF00
#define YELLOW "colour226"   // #FFFF00
#define GREEN "colour118"    // #87FF00
#define WHITE "colour231"    // #FFFFFF
#define LIGHT_BG "colour237" // #303030
#define DARK_BG "colour236"  // #3A3A3A
#define TEXT WHITE

int8_t interfaceStatus(const char *interface) {
  int8_t length = 15                  // path start
                  + strlen(interface) // interface
                  + 8                 // path end
                  + 1;                // null character
  char *interfaceStatusFilePath = malloc(length);
  strcat(interfaceStatusFilePath, "/sys/class/net/");
  strcat(interfaceStatusFilePath, interface);
  strcat(interfaceStatusFilePath, "/carrier");

  FILE *statusFile = fopen(interfaceStatusFilePath, "r");
  char status[2];
  fgets(status, 2, statusFile);
  fclose(statusFile);
  free(interfaceStatusFilePath);

  return atoi(status);
}

// Modify input string and only keep [0-9]
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
  /*
   * Power
   */
  fputs("#[bg=" LIGHT_BG "]", stdout);

  FILE *acStatusFile = fopen(AC_STATUS_FILE, "r");
  char acStatus = fgetc(acStatusFile);
  fclose(acStatusFile);

  if (acStatus == '1') {
    fputs("#[fg=" GREEN ",bold] AC ⌁ ", stdout);
  } else {
    FILE *batteryLevelFile = fopen(BATTERY_LEVEL_FILE, "r");

    char batteryLevelString[4];
    fgets(batteryLevelString, 4, batteryLevelFile);
    fclose(batteryLevelFile);

    int batteryLevel = atoi(batteryLevelString);

    if (batteryLevel > 75) {
      fputs("#[fg=" GREEN "]", stdout);
    } else if (batteryLevel > 50) {
      fputs("#[fg=" ORANGE "]", stdout);
    } else {
      fputs("#[fg=" RED ",reverse]", stdout);
    }
    fprintf(stdout, " %2d %% ", batteryLevel);
  }
  resetStyles();

  /*
   * CPU Temp
   */
  FILE *cpuTempFile = fopen(CPU_TEMP_FILE, "r");
  char cpuTempString[3];
  fgets(cpuTempString, 3, cpuTempFile);
  fclose(cpuTempFile);

  int cpuTemp = atoi(cpuTempString);

  fputs("#[bg=" DARK_BG "]", stdout);
  if (cpuTemp > 80) {
    fputs("#[fg=" RED ",reverse]", stdout);
  } else if (cpuTemp > 50) {
    fputs("#[fg=" ORANGE "]", stdout);
  } else {
    fputs("#[fg=" GREEN "]", stdout);
  }
  fprintf(stdout, " %d°C ", cpuTemp);
  resetStyles();

  /*
   * Load Avg
   */
  FILE *loadAvgFile = fopen(LOAD_AVG_FILE, "r");
  char loadAvg[5];
  fgets(loadAvg, 5, loadAvgFile);
  fclose(loadAvgFile);

  fprintf(stdout, "#[fg=" WHITE ",bg=" LIGHT_BG "] %s ", loadAvg);

  /*
   * Memory Usage
   */
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

  fputs("#[bg=" DARK_BG "]", stdout);
  if (usedMemoryPercentage > 75) {
    fputs("#[fg=" RED ",reverse]", stdout);
  } else if (usedMemoryPercentage > 50) {
    fputs("#[fg=" ORANGE "]", stdout);
  } else {
    fputs("#[fg=" GREEN "]", stdout);
  }
  fprintf(stdout, " %2.f%% ", usedMemoryPercentage);
  resetStyles();

  /*
   * Fan Speed
   */
  FILE *fanFile = fopen(FAN_STATUS_FILE, "r");
  char *fanStatusLine = NULL;
  char *fanSpeedLine = NULL;
  /* We don't actually care about this one, but it's first */
  getline(&fanStatusLine, &size, fanFile);
  getline(&fanSpeedLine, &size, fanFile);
  fclose(fanFile);

  stripNonDigits(fanSpeedLine, strlen(fanSpeedLine));
  int fanSpeed = atoi(fanSpeedLine);

  fprintf(stdout, "#[fg=" WHITE ",bg=" LIGHT_BG "] %4d ", fanSpeed);

  /*
   * Network Status
   */
  fprintf(stdout, "#[fg=" WHITE ",bg=" DARK_BG "]");

  int8_t ethernetStatus = interfaceStatus(ETHERNET_INTERFACE);
  int8_t wirelessStatus = interfaceStatus(WIRELESS_INTERFACE);
  if (ethernetStatus) {
    // TODO any neat stats we can get?
    fputs("#[fg=" GREEN "] WIRED ↑ ", stdout);
  } else if (wirelessStatus) {
    FILE *wirelessFile = fopen(WIRELESS_FILE, "r");
    char *wirelessHeaderLine = NULL;
    char *wirelessInterfaceLine = NULL;
    size_t wirelessSize = 0;
    /* Two header lines */
    getline(&wirelessHeaderLine, &wirelessSize, wirelessFile);
    getline(&wirelessHeaderLine, &wirelessSize, wirelessFile);

    // TODO support more than one interface, we blindly assume that the one we
    // care about is the first and only
    getline(&wirelessInterfaceLine, &wirelessSize, wirelessFile);
    // In my case, this line looks like this:
    // wlp3s0: 0000   67.  -43.  -256        0      0      0      0    303 0
    //
    // Since we only care about the 4th column (-43)
    // If we split the string by ".", we only need index 1, and we can discard
    // unwanted data.
    fclose(wirelessFile);

    if (strlen(wirelessInterfaceLine) == 0) {
      // Should not really get here buuut
      fputs("#[fg=" RED ",reverse] OFFLINE ↓ ", stdout);
    } else {
      // RSSI (signal quality in dBm) first
      char *token = strtok(wirelessInterfaceLine, ".");
      token = strtok(NULL, ".");
      stripNonDigits(token, strlen(token));

      // This is a negative number, but we discard the `-`
      int signal = atoi(token);

      struct iwreq wreq;
      int sockfd;
      char *id[32];

      // Allocate memory for the request
      memset(&wreq, 0, sizeof(struct iwreq));
      // Assign our interface name to the request
      sprintf(wreq.ifr_name, WIRELESS_INTERFACE);

      // Open socket for ioctl
      if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        fprintf(stderr, "FAILED 1");
        exit(1);
      }

      wreq.u.essid.pointer = id;
      wreq.u.essid.length = 32;
      if (ioctl(sockfd, SIOCGIWESSID, &wreq) == -1) {
        fprintf(stderr, "FAILED 2");
        exit(2);
      }

      if (signal > 70) {
        fputs("#[fg=" RED "]", stdout);
      } else if (signal > 60) {
        fputs("#[fg=" ORANGE "]", stdout);
      } else if (signal > 50) {
        fputs("#[fg=" YELLOW "]", stdout);
      } else {
        fputs("#[fg=" GREEN "]", stdout);
      }
      fputc(' ', stdout);
      fwrite(wreq.u.essid.pointer, 1, wreq.u.essid.length, stdout);
      fprintf(stdout, " %d", signal);
      fputs("#[fg=" GREEN "] ↑ ", stdout);
    }
  } else {
    fputs("#[fg=" RED ",reverse] OFFLINE ↓ ", stdout);
  }
  resetStyles();

  /*
   * VPN Status
   */
  fputs("#[bg=" LIGHT_BG ",bold]", stdout);

  struct stat buffer;
  int exists = stat(WIREGUARD_INTERFACE_FILE, &buffer);
  if (exists == 0) {
    fputs("#[fg=" GREEN "] VPN ↑ ", stdout);
  } else {
    fputs("#[fg=" RED "] VPN ↓ ", stdout);
  }
  resetStyles();

  /*
   * Day Month, Year
   */
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
          "#[fg=colour146,bold,bg=" DARK_BG "] %s "
          "#[fg=colour176,bold,bg=" DARK_BG "]%s, "
          "#[fg=colour173,bold,bg=" DARK_BG "]%s#[fg=default] ",
          day, month, year);

  /*
   * Time 24HR
   */
  char time[6];
  strftime(time, sizeof(time), "%R", info);

  // B REDY 4 SUM QUIK MAFFS

  // https://stjarnhimlen.se/comp/ppcomp.html#3
  // Compute day number by converting calendar date to Julian Day Number
  // tm_year is indexed from 1900
  // tm_mon are indexed from 0
  // Needs to be INTEGER division hence the floor
  double d =
      (367 * (info->tm_year + 1900) -
       floor((7 * ((info->tm_year + 1900) +
                   floor(((info->tm_mon + 1) + 9) / 12.0))) /
             4.0) +
       floor((275 * (info->tm_mon + 1)) / 9.0) + (info->tm_mday) - 730530);

  // Sun rise/set - https://stjarnhimlen.se/comp/riset.html
  // Sun's orbital elements from https://stjarnhimlen.se/comp/ppcomp.html#4.1
  double w = 282.9404 + 4.70935E-5 * d;   // argument of perihelion
  double e = 0.016709 - 1.151E-9 * d;     // eccentricity
  double M = 356.0470 + 0.9856002585 * d; // mean anomaly
  double ecl = 23.4393 - 3.563E-7 * d;    // obliquity of the ecliptic
  // https://stjarnhimlen.se/comp/ppcomp.html#5
  double E = M + e * RADEG * sind(M) * (1.0 + e * cosd(M)); // eccentric anomaly
  double x = cosd(E) - e;
  double y = sqrt(1.0 - e * e) * sind(E);
  double r = sqrt(x * x + y * y); // distance
  double v = atan2d(y, x);        // true anomaly
  double sunTrueLongitude = v + w;
  if (sunTrueLongitude >= 360.0) {
    sunTrueLongitude -= 360.0;
  }
  /* Convert sunTrueLongitude,r to ecliptic rectangular geocentric coordinates
   * xs,ys: */
  double xs = r * cosd(sunTrueLongitude);
  double ys = r * sind(sunTrueLongitude);

  /* To convert this to equatorial, rectangular, geocentric coordinates,
   * compute: */
  double xe = xs;
  double ye = ys * cosd(ecl);
  double ze = ys * sind(ecl);
  /* Finally, compute the Sun's Right Ascension (RA) and Declination (Dec): */
  double rightAscension = atan2d(ye, xe);
  double declination = atan2d(ze, sqrt(xe * xe + ye * ye));
  double sunMeanLongitude = M + w;
  // Sidereal time at Greenwich at 00:00 Universal Time
  double GMST0 = sunMeanLongitude + 180.0;

  double universalTime =
      (info->tm_hour -
       info->tm_gmtoff / 3600.0) // remove offset (seconds) from hours
      + (info->tm_min / 60.0);
  double localSiderealTime = GMST0 + (universalTime * 15.04107) + LNG;

  double localHourAngle = localSiderealTime - rightAscension;

  double sunAngle = asind(sind(LAT) * sind(declination) +
                          cosd(LAT) * cosd(declination) * cosd(localHourAngle));

  char *textColour;
  char *bgColour;

  if (sunAngle < -18) {
    // night
    textColour = WHITE;
    bgColour = "colour16"; // #000000
  } else if (sunAngle >= -18 && sunAngle < -12) {
    // astronomical twilight
    textColour = WHITE;
    bgColour = "colour19"; // #0000AF
  } else if (sunAngle >= -18 && sunAngle < -6) {
    // nautical twilight
    textColour = WHITE;
    bgColour = "colour21"; // #0000FF
  } else if (sunAngle >= -6 && sunAngle < -0.833) {
    // civil twilight
    textColour = WHITE;
    bgColour = "colour27"; // #005FFF
  } else if (sunAngle >= -0.833 && sunAngle < 0) {
    // sunrise/sunset
    textColour = WHITE;
    bgColour = "colour167"; // #d75f5f
  } else if (sunAngle > 0) {
    // day
    textColour = DARK_BG;
    bgColour = "colour4"; // #00AFFF
  }

  fprintf(stdout, "#[fg=%s,bold,bg=%s] %s ", textColour, bgColour, time);

  return 0;
}
