#include <ctype.h>
#include <errno.h>
#include <linux/wireless.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/sysinfo.h>
#include <sys/types.h>
#include <time.h>

#define AC_STATUS_FILE "/sys/class/power_supply/AC/online"
#define BATTERY_LEVEL_FILE "/sys/class/power_supply/BAT0/capacity"
#define CPU_TEMP_FILE "/sys/class/hwmon/hwmon6/temp1_input"
#define CPU_TEMP_FACTOR 1000
#define FAN_STATUS_FILE "/proc/acpi/ibm/fan"
#define WIREGUARD_INTERFACE_FILE "/proc/net/dev_snmp6/wg0"
#define ETHERNET_INTERFACE "enp1s0f0"
#define WIRELESS_INTERFACE "wlp2s0"

// Not actually my location, but close enough
#define LAT 55.116889
#define LNG -4.436861

// Trigonometry for sun position calculations
#define PI 3.1415926535897932384
#define RADEG (180.0 / PI)
#define DEGRAD (PI / 180.0)
#define sind(x) sin((x) * DEGRAD)
#define cosd(x) cos((x) * DEGRAD)
#define tand(x) tan((x) * DEGRAD)
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

int8_t interfaceStatus(const char *interface);
void stripNonDigits(char *input, int length);
void resetStyles();
int fileToNumber(char *filename);

int8_t interfaceStatus(const char *interface) {
  int8_t length = 15                  // path start
                  + strlen(interface) // interface
                  + 8                 // path end
                  + 1;                // null character
  char *interfaceStatusFilePath = calloc(length, sizeof(char));
  strcat(interfaceStatusFilePath, "/sys/class/net/");
  strcat(interfaceStatusFilePath, interface);
  strcat(interfaceStatusFilePath, "/carrier");
  // Implicitly ends with \0 after strcat

  return fileToNumber(interfaceStatusFilePath);
}

// Modify input string and only keep [0-9]
void stripNonDigits(char *input, int length) {
  char *output = calloc(length, sizeof(char));
  int index = 0;
  char *sPtr = input;

  for (; *sPtr != '\0'; sPtr++) {
    if (isdigit(*sPtr)) {
      output[index++] = *sPtr;
    }
  }

  strcpy(input, output);
  free(output);
}

void resetStyles() { printf("#[default]"); }

int fileToNumber(char *filename) {
  FILE *file = fopen(filename, "r");
  int buflen = 64;
  char string[buflen];
  fgets(string, buflen, file);
  fclose(file);
  return atoi(string);
}

int main() {
  /*
   * Power
   */
  printf("#[bg=" LIGHT_BG "]");

  int acStatus = fileToNumber(AC_STATUS_FILE);
  int batteryLevel = fileToNumber(BATTERY_LEVEL_FILE);

  if (acStatus == 1) {
    printf("#[fg=" GREEN ",bold] AC ⌁ ");
    if (batteryLevel < 75) {
      if (batteryLevel > 50) {
        printf("#[fg=" ORANGE "]");
      } else {
        printf("#[fg=" RED "]");
      }
      printf("(%2d %%) ", batteryLevel);
    }
  } else {
    if (batteryLevel > 75) {
      printf("#[fg=" GREEN "]");
    } else if (batteryLevel > 50) {
      printf("#[fg=" ORANGE "]");
    } else {
      printf("#[fg=" RED ",reverse]");
    }
    printf(" %2d %% ", batteryLevel);
  }
  resetStyles();

  /*
   * CPU Temp
   */
  int cpuTemp = fileToNumber(CPU_TEMP_FILE) / CPU_TEMP_FACTOR;

  printf("#[bg=" DARK_BG "]");
  if (cpuTemp > 80) {
    printf("#[fg=" RED ",reverse]");
  } else if (cpuTemp > 50) {
    printf("#[fg=" ORANGE "]");
  } else {
    printf("#[fg=" GREEN "]");
  }
  printf(" %d°C ", cpuTemp);
  resetStyles();

  /* sysinfo struct used for multiple things */
  struct sysinfo sysInfo;
  int err = sysinfo(&sysInfo);
  if (err == -1) {
    fprintf(stderr, "FAILED 1");
    exit(1);
  }

  /*
   * Load Avg
   */
  float loadAvg = sysInfo.loads[0] / (float)(1 << SI_LOAD_SHIFT);

  printf("#[fg=" WHITE ",bg=" LIGHT_BG "] %2.2f ", loadAvg);

  /*
   * Memory Usage
   */

  u_int64_t memoryTotal = (sysInfo.totalram * sysInfo.mem_unit);
  u_int64_t memoryAvailable =
      ((sysInfo.freeram + sysInfo.bufferram) * sysInfo.mem_unit);
  double freeMemoryPercentage = ((double)memoryAvailable / memoryTotal) * 100;
  double usedMemoryPercentage = 100 - freeMemoryPercentage;

  printf("#[bg=" DARK_BG "]");
  if (usedMemoryPercentage > 75) {
    printf("#[fg=" RED ",reverse]");
  } else if (usedMemoryPercentage > 50) {
    printf("#[fg=" ORANGE "]");
  } else {
    printf("#[fg=" GREEN "]");
  }
  printf(" %2.f%% ", usedMemoryPercentage);
  resetStyles();

  /*
   * Fan Speed
   */
  FILE *fanFile = fopen(FAN_STATUS_FILE, "r");
  char *fanStatusLine = NULL;
  char *fanSpeedLine = NULL;
  size_t size = 0;
  /* We don't actually care about this one, but it's first */
  getline(&fanStatusLine, &size, fanFile);
  getline(&fanSpeedLine, &size, fanFile);
  fclose(fanFile);

  stripNonDigits(fanSpeedLine, strlen(fanSpeedLine));
  int fanSpeed = atoi(fanSpeedLine);

  free(fanStatusLine);
  free(fanSpeedLine);

  printf("#[fg=" WHITE ",bg=" LIGHT_BG "] %4d ",
         // after wake from sleep this seems to be the value
         fanSpeed == 65535 ? 0 : fanSpeed);

  /*
   * Network Status
   * TODO broken on 5.15.0
   * https://unix.stackexchange.com/q/724019/548295
   * Tried with nl80211, same result
   * nl example https://github.com/bmegli/wifi-scan
   */
  printf("#[fg=" WHITE ",bg=" DARK_BG "]");

  int8_t ethernetStatus = interfaceStatus(ETHERNET_INTERFACE);
  int8_t wirelessStatus = interfaceStatus(WIRELESS_INTERFACE);
  if (ethernetStatus) {
    // TODO any neat stats we can get?
    printf("#[fg=" GREEN "] WIRED ↑ ");
  } else if (wirelessStatus) {
    // Communicate using ioctl to get information
    struct iwreq ssidReq, signalReq;
    int sockfd;
    char *ssid[32];

    // Allocate memory for the request
    memset(&ssidReq, 0, sizeof(struct iwreq));
    memset(&signalReq, 0, sizeof(struct iwreq));
    // Assign our interface name to the request
    sprintf(ssidReq.ifr_name, WIRELESS_INTERFACE);
    sprintf(signalReq.ifr_name, WIRELESS_INTERFACE);

    // Open socket for ioctl
    if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
      fprintf(stderr, "FAILED 2");
      exit(2);
    }

    // Get SSID
    ssidReq.u.essid.pointer = ssid;
    ssidReq.u.essid.length = 32;
    if (ioctl(sockfd, SIOCGIWESSID, &ssidReq) == -1) {
      fprintf(stderr, "FAILED 3");
      exit(3);
    }

    struct iw_statistics *stats;
    int8_t signal = 0;

    signalReq.u.data.pointer = (struct iw_statistics *)malloc(sizeof(*stats));
    signalReq.u.data.length = sizeof(*stats);
    signalReq.u.data.flags = 1;
    if (ioctl(sockfd, SIOCGIWSTATS, &signalReq) == -1) {
      fprintf(stderr, "FAILED 4");
      exit(4);
    }
    if (((struct iw_statistics *)signalReq.u.data.pointer)->qual.updated &
        IW_QUAL_DBM) {
      // signal is measured in dBm and is valid for us to use
      signal =
          ((struct iw_statistics *)signalReq.u.data.pointer)->qual.level - 256;
      free(signalReq.u.data.pointer);
    }
    if (signal > 70) {
      printf("#[fg=" RED "]");
    } else if (signal > 60) {
      printf("#[fg=" ORANGE "]");
    } else if (signal > 50) {
      printf("#[fg=" YELLOW "]");
    } else {
      printf("#[fg=" GREEN "]");
    }
    printf(" ");
    fwrite(ssidReq.u.essid.pointer, 1, ssidReq.u.essid.length, stdout);

    printf(" %d", signal);
    printf("#[fg=" GREEN "] ↑ ");
  } else {
    printf("#[fg=" RED ",reverse] OFFLINE ↓ ");
  }
  resetStyles();

  /*
   * VPN Status
   * TODO support multiple vpns
   *  - AWS
   *  - Mullvad
   */
  printf("#[bg=" LIGHT_BG ",bold]");

  struct stat buffer;
  int exists = stat(WIREGUARD_INTERFACE_FILE, &buffer);
  if (exists == 0) {
    printf("#[fg=" GREEN "] VPN ↑ ");
  } else {
    printf("#[fg=" RED "] VPN ↓ ");
  }
  resetStyles();

  /*
   * Day Month, Year
   */
  char day[3];
  char month[10];
  char year[5];
  time_t rawtime;
  struct tm *timeInfo;

  time(&rawtime);
  timeInfo = localtime(&rawtime);

  strftime(day, sizeof(day), "%d", timeInfo);
  strftime(month, sizeof(month), "%B", timeInfo);
  strftime(year, sizeof(year), "%Y", timeInfo);

  printf("#[fg=colour146,bold,bg=" DARK_BG "] %s "
         "#[fg=colour176,bold,bg=" DARK_BG "]%s, "
         "#[fg=colour173,bold,bg=" DARK_BG "]%s#[fg=default] ",
         day, month, year);

  /*
   * Time 24HR
   */
  char time[6];
  strftime(time, sizeof(time), "%R", timeInfo);

  // B REDY 4 SUM QUIK MAFFS

  // https://stjarnhimlen.se/comp/ppcomp.html#3
  // Compute day number by converting calendar date to Julian Day Number
  // tm_year is indexed from 1900
  // tm_mon are indexed from 0
  // Needs to be INTEGER division hence the floor
  double d = (367 * (timeInfo->tm_year + 1900) -
              floor((7 * ((timeInfo->tm_year + 1900) +
                          floor(((timeInfo->tm_mon + 1) + 9) / 12.0))) /
                    4.0) +
              floor((275 * (timeInfo->tm_mon + 1)) / 9.0) +
              (timeInfo->tm_mday) - 730530);

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
      (timeInfo->tm_hour -
       timeInfo->tm_gmtoff / 3600.0) // remove offset (seconds) from hours
      + (timeInfo->tm_min / 60.0);
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

  printf("#[fg=%s,bold,bg=%s] %s ", textColour, bgColour, time);

  return 0;
}
