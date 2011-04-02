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


using namespace std;

static string buffer;

//======================= DEVICE STUFF =======================

string device_get_name(string map) {
	DIR *dp;
	struct dirent *ep;
	size_t map_length = strlen(map.c_str());
	string dev_name;
	string dirname = "/dev/";

	dp = opendir(dirname.c_str());

	if (dp != NULL) {
		while (ep = readdir (dp)) {
			dev_name = ep->d_name;
			dev_name = dev_name.substr(0, map_length);
			if (strcmp(dev_name.c_str(), map.c_str()) == 0) {
				dev_name = ep->d_name;
				dev_name = dirname + dev_name;
				closedir (dp);

				return dev_name;
			}
		}
	}

	return "";
}

int device_open_port() {

	string dev_name_str = device_get_name("tty.usbmodem");
	const char* dev_name = dev_name_str.c_str();
	if (strlen(dev_name) == 0) {
		return -1;
	}

	int descr = open(dev_name, O_RDWR | O_NOCTTY | O_NDELAY);

	if (descr == -1) {
		printf("Unable to open serial port\n");
	} else {
		fcntl(descr, F_SETFL, 0);
	}

	return descr;
}

int device_configure_port(int descr) {

	struct termios port_settings;

	cfsetispeed(&port_settings, B9600);
	cfsetospeed(&port_settings, B9600);

	port_settings.c_cflag &= ~PARENB;
	port_settings.c_cflag &= ~CSTOPB;
	port_settings.c_cflag &= ~CSIZE;
	port_settings.c_cflag |= CS8;
}

int device_write_data(int descr, int color) {

	unsigned char bytes[] = { color };

	write(descr, bytes, 1);

	return 0;
}

//======================= END OF DEVICE STUFF =======================



//======================= XML RETRIEVING AND PARING =======================

static int writer(char *data, size_t size, size_t nmemb, string *buffer) {

	int result = 0;

	if (buffer != NULL) {

		buffer->append(data, size * nmemb);

		result = size * nmemb;
	}

	return result;
}

string perform_request(string url) {

	CURL *curl;
	CURLcode res;

	curl = curl_easy_init();

	if (curl) {

		curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
		curl_easy_setopt(curl, CURLOPT_HEADER, 0);
		curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writer);
		curl_easy_setopt(curl, CURLOPT_WRITEDATA, &buffer);
		res = curl_easy_perform(curl);
		curl_easy_cleanup(curl);

		if (!res) {

			return buffer;
		}
	}

	return "";
}

string parse(string response) {

	string p_start("<icon>"), p_stop("</icon>"), buffer("");
	int start, stop;

	start = response.find(p_start);
	stop = response.find(p_stop);

	if ((start != string::npos) && (stop != string::npos)) {

		start += p_start.length();
		buffer = response.substr(start, stop - start);
	}

	return buffer;
}

//======================= END OF XML RETRIEVING AND PARING =======================


int set_traffic_light(int descr, int light) {

	device_write_data(descr, light);

	return 0;
}

int main(int argc, char* argv[]) {

	string response;
	string message;

	string url = "http://export.yandex.ru/bar/reginfo.xml?region=1";

	int light = -1;

	int descr = device_open_port();

	if (descr == -1) {
		cout << "No device found" << "\n";
		return 1;
	}

	device_configure_port(descr);

	while (true) {
		response = perform_request(url);

		if (response != "") {

			message = parse(response);

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