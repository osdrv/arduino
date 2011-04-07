#include <stdio.h>
#include <iostream>
#include <string.h>
#include <curl/curl.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <time.h>
#include <stdlib.h>
#include <sys/types.h>
#include <dirent.h>

#include "device.h"
#include "xml.h"

const string URL = "http://export.yandex.ru/bar/reginfo.xml?region=1";

int set_traffic_light(int descr, int light) {

	device_write_data(descr, light);

	return 0;
}

int main(int argc, char* argv[]) {

	string response;
	string message;

	int light = -1;

	int descr = device_open_port();

	if (descr == -1) {
		cout << "No device found" << "\n";
		return 1;
	}

	device_configure_port(descr);

	int rc;
	if (fork() != 0)
		exit(0);
	setsid();

	while (true) {
		response = perform_request(URL);
		// cout << response << "\n";
		if (response != "") {

			message = parse(response);
			// cout << message << "\n";
			if (message == "green") {
				light = 0;
			} else if (message == "yellow") {
				light = 1;
			} else if (message == "red") {
				light = 2;
			}

			set_traffic_light(descr, light);
		}

		sleep(60);
	}

	exit(0);
}
