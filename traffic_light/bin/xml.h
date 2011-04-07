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
	string buffer;
	
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
