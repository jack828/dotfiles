#include <errno.h>
#include <linux/sysinfo.h>
#include <linux/wireless.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>

#define WIRELESS_INTERFACE "wlp2s0"

#include <sys/sysinfo.h>

/* int sysinfo(struct sysinfo *info); */

int main() {
  struct sysinfo info;
  int err = sysinfo(&info);
  fprintf(stdout, "%lu\n", (info.totalram * info.mem_unit));
  u_int64_t totalMemory = (info.totalram * info.mem_unit);
  u_int64_t availableMemory =
      ((info.freeram + info.bufferram) * info.mem_unit);
  double freeMemoryPercentage = ((double) availableMemory / totalMemory) * 100;
  double usedMemoryPercentage = 100 - freeMemoryPercentage;
  fprintf(stdout, "\n\n%lu\n", availableMemory);
  fprintf(stdout, "\n\n %2.f%% \n", usedMemoryPercentage);
  /*
  // Communicate using ioctl to get information
  struct iwreq wreq;
  int sockfd;
  char *ssid[32];

  // Allocate memory for the request
  memset(&wreq, 0, sizeof(struct iwreq));
  // Assign our interface name to the request
  sprintf(wreq.ifr_name, WIRELESS_INTERFACE);

  struct iwreq wreq2;

  // Allocate memory for the request
  memset(&wreq2, 0, sizeof(struct iwreq));
  // Assign our interface name to the request
  sprintf(wreq2.ifr_name, WIRELESS_INTERFACE);

  // Open socket for ioctl
  if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
    fprintf(stderr, "FAILED 1");
    exit(1);
  }

  // Get SSID
  wreq.u.essid.pointer = ssid;
  wreq.u.essid.length = 32;
  if (ioctl(sockfd, SIOCGIWESSID, &wreq) == -1) {
    fprintf(stderr, "FAILED 2");
    exit(2);
  }

  fwrite(wreq.u.essid.pointer, 1, wreq.u.essid.length, stdout);

  struct iw_statistics *stats;
  int8_t signalLevel = 0;

  wreq2.u.data.pointer = (struct iw_statistics *)malloc(sizeof(*stats));
  wreq2.u.data.length = sizeof(*stats);
  wreq2.u.data.flags = 1;
  if (ioctl(sockfd, SIOCGIWSTATS, &wreq2) == -1) {
    fprintf(stderr, "FAILED 2");
    exit(2);
  }
  if (((struct iw_statistics *)wreq2.u.data.pointer)->qual.updated &
      IW_QUAL_DBM) {
    fputs("\nSignal valid\n", stdout);
    // signal is measured in dBm and is valid for us to use
    signalLevel =
        ((struct iw_statistics *)wreq2.u.data.pointer)->qual.level - 256;
  }
  fprintf(stdout, "\nsignalLevel %d\n", signalLevel);
  */
}
