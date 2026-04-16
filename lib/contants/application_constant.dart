import 'dart:async';

import 'package:flutter/services.dart';
import "package:shared_preferences/shared_preferences.dart";

class ApplicationConstant {
  static String token = "";
  static String name = "";

  static String applicationId = "";
  static String firmId = "";
  static String hamamSpaApiUrl = "";
  static String kantincimApiUrl = "";
  static String gymTrainingApiUrl = "";
  static String randevuAlApiUrl = "";
  static String digitalSignageApiUrl = "";
  static String programeName = "";

  static String applicationIdKey = "application_id";
  static String firmIdKey = "firm_id";
  static String hamamSpaApiUrlKey = "hamam_spa_api_url";
  static String kantincimApiUrlKey = "kantincim_api_url";
  static String gymTrainingApiUrlKey = "gym_training_api_url";
  static String randevuOnlineApiUrlKey = "randevu_online_api_url";
  static String digitalSignageApiUrlKey = "digital_signage_api_url";
  static String securityKeyApiUrlKey = "security_key_api_url";
  static String hostKey = "host";
  static String memberIdKey = "member_id";
  static String nameKey = "name";
  static String phoneKey = "phone";
  static String birthdayKey = "birthday";
  static String genderKey = "gender";
  static String tokenKey = "esport_token";
  static String imageUrlKey = "image";
  static String thumbImageUrlKey = "thumb_image";
  static String userKey = "user";
  static String fitnessProgrameName = "fitness_programe";
  static String securityKey = "security_key";

  static String deneme = "";

  static Future<void> saveStringValue(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } on PlatformException {
      // Non-blocking: cache write failures should not crash runtime flow.
    }
  }

  static Future<String?> getStringValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } on PlatformException {
      return null;
    }
  }

  static Future<void> getMemberIdValue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      deneme = prefs.getString(memberIdKey) ?? "";
    } on PlatformException {
      deneme = "";
    }
  }

  static Future<void> saveIntValue(String key, int value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(key, value);
    } on PlatformException {
      // Non-blocking: cache write failures should not crash runtime flow.
    }
  }

  static Future<int?> getIntValue(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key);
    } on PlatformException {
      return null;
    }
  }

  static void setUser(String token) {
    saveStringValue(tokenKey, token);
    token = token;
  }

  static void setToken(String token) {
    saveStringValue(tokenKey, token);
    token = token;
  }

  static void setName(String name) {
    saveStringValue(nameKey, name);
    name = name;
  }

  static void setFitnessPrograme(String fitnessPrograme) {
    saveStringValue(fitnessProgrameName, fitnessPrograme);
    programeName = fitnessPrograme;
  }

  static void setApplicationId(String applicationId) {
    saveStringValue(applicationIdKey, applicationId);
    applicationId = applicationId;
  }

  static void setFirmId(String firmId) {
    saveStringValue(firmIdKey, firmId);
    firmId = firmId;
  }

  static void setHamamSpaApiUrl(String hamamSpaApiUrl) {
    saveStringValue(hamamSpaApiUrlKey, hamamSpaApiUrl);
    hamamSpaApiUrl = hamamSpaApiUrl;
  }

  static void setKantincimApiUrl(String kantincimApiUrl) {
    saveStringValue(kantincimApiUrlKey, kantincimApiUrl);
    kantincimApiUrl = kantincimApiUrl;
  }

  static void setGymTrainingApiUrl(String gymTrainingApiUrl) {
    saveStringValue(gymTrainingApiUrlKey, gymTrainingApiUrl);
    gymTrainingApiUrl = gymTrainingApiUrl;
  }

  static void setRandevuAlApiUrl(String randevuAlApiUrl) {
    saveStringValue(randevuOnlineApiUrlKey, randevuAlApiUrl);
    randevuAlApiUrl = randevuAlApiUrl;
  }

  static void setDigitalSignageApiUrl(String digitalSignageApiUrl) {
    saveStringValue(digitalSignageApiUrlKey, digitalSignageApiUrl);
    digitalSignageApiUrl = digitalSignageApiUrl;
  }

  static void setHost(String host) {
    saveStringValue(hostKey, host);
    host = host;
  }

  static void setMemberId(String memberId) {
    saveStringValue(memberIdKey, memberId);
    memberId = memberId;
  }

  static void setPhone(String phone) {
    saveStringValue(phoneKey, phone);
    phone = phone;
  }

  static void setBirthday(String birthday) {
    saveStringValue(birthdayKey, birthday);
    birthday = birthday;
  }

  static void setGender(String gender) {
    saveStringValue(genderKey, gender);
    gender = gender;
  }

  static void setImageUrl(String imageUrl) {
    saveStringValue(imageUrlKey, imageUrl);
    imageUrl = imageUrl;
  }

  static void setThumbImageUrl(String thumbImageUrl) {
    saveStringValue(thumbImageUrlKey, thumbImageUrl);
    thumbImageUrl = thumbImageUrl;
  }

  static void setSecurityKey(String securityKeyUrl) {
    saveStringValue(securityKeyApiUrlKey, securityKeyUrl);
    securityKey = securityKeyUrl;
  }

  // static void setKantincimApiUrl(String kantincimApiUrl) {
  //   saveStringValue(kantincimApiUrlKey, kantincimApiUrl);
  //   kantincimApiUrl = kantincimApiUrl;
  // }

  static Future<String?> getApplicationId() async {
    return await getStringValue(applicationIdKey);
  }

  static Future<String?> getImageUrl() async {
    return await getStringValue(imageUrlKey);
  }

  static Future<String?> getFirmId() async {
    return await getStringValue(firmIdKey);
  }

  static Future<String?> getHamamSpaApiUrl() async {
    return await getStringValue(hamamSpaApiUrlKey);
  }

  static Future<String?> getKantincimApiUrl() async {
    return await getStringValue(kantincimApiUrlKey);
  }

  static Future<String?> getGymTrainingApiUrl() async {
    return await getStringValue(gymTrainingApiUrlKey);
  }

  static Future<String?> getRandevuAlOnlineApiUrl() async {
    return await getStringValue(randevuOnlineApiUrlKey);
  }

  static Future<String?> getDigitalSignageOnlineApiUrl() async {
    return await getStringValue(digitalSignageApiUrlKey);
  }

  // static Future<String?> getKantincimApiUrl() async {
  //   return await getStringValue(kantincimApiUrlKey);
  // }

  static Future<String?> getToken() async {
    return await getStringValue(tokenKey);
  }

  static Future<String?> getName() async {
    return await getStringValue(nameKey);
  }

  static Future<String?> getSecurityKeyUrl() async {
    return await getStringValue(securityKey);
  }
}
