import 'package:flutter/material.dart';
import 'package:poem_diary/l10n/app_localizations.dart';

class LocalizationHelper {
  static String getActivityName(
    BuildContext context,
    String activityKey, [
    dynamic value,
  ]) {
    final loc = AppLocalizations.of(context)!;

    switch (activityKey) {
      // --- SLEEP ---
      case 'sleep':
        if (value == 'good') return loc.sleepGood;
        if (value == 'medium') return loc.sleepMedium;
        if (value == 'bad') return loc.sleepBad;
        return loc.sectionSleep; // Fallback or title

      // --- WEATHER ---
      case 'weather':
        if (value == 'sunny') return loc.weatherSunny;
        if (value == 'rainy') return loc.weatherRainy;
        if (value == 'cloudy') return loc.weatherCloudy;
        if (value == 'snowy') return loc.weatherSnowy;
        if (value == 'windy') return loc.weatherWindy;
        if (value == 'foggy') return loc.weatherFoggy;
        if (value == 'hail') return loc.weatherHail;
        return loc.sectionWeather;

      case 'sunny':
        return loc.weatherSunny;
      case 'rainy':
        return loc.weatherRainy;
      case 'cloudy':
        return loc.weatherCloudy;
      case 'snowy':
        return loc.weatherSnowy;
      case 'windy':
        return loc.weatherWindy;
      case 'foggy':
        return loc.weatherFoggy;
      case 'hail':
        return loc.weatherHail;

      // --- GOALS / HABITS ---
      case 'no_smoking':
        return loc.goalNoSmoking;
      case 'social_media_detox':
        return loc.goalSocialDetox;
      case 'read_book':
        return loc.goalReadBook;
      case 'drink_water':
        return loc.goalDrinkWater;
      case 'meditation':
        return loc.goalMeditation;
      case 'early_rise':
        return loc.goalEarlyRise;
      case 'no_sugar':
        return loc.goalNoSugar;
      case 'journaling':
        return loc.goalJournaling;
      case '10k_steps':
        return loc.goalSteps;

      // --- HEALTH ---
      case 'sport':
        return loc.healthSport;
      case 'healthy_food':
        return loc.healthHealthyFood;
      case 'fast_food':
        return loc.healthFastFood;
      case 'water':
        return loc.healthWater;
      case 'walking':
        return loc.healthWalking;
      case 'vitamins':
        return loc.healthVitamins;
      case 'sleep_health':
        return loc.healthSleep;
      case 'doctor':
        return loc.healthDoctor;

      // --- SOCIAL ---
      case 'friends':
        return loc.socialFriends;
      case 'family':
        return loc.socialFamily;
      case 'party':
        return loc.socialParty;
      case 'partner':
        return loc.socialPartner;
      case 'guests':
        return loc.socialGuests;
      case 'colleagues':
        return loc.socialColleagues;
      case 'travel':
        return loc.socialTravel;
      case 'volunteer':
        return loc.socialVolunteer;

      // --- HOBBIES ---
      case 'gaming':
        return loc.hobbyGaming;
      case 'reading':
        return loc.hobbyReading;
      case 'movie':
        return loc.hobbyMovie;
      case 'art':
        return loc.hobbyArt;
      case 'music':
        return loc.hobbyMusic;
      case 'coding':
        return loc.hobbyCoding;
      case 'photography':
        return loc.hobbyPhotography;
      case 'crafts':
        return loc.hobbyCrafts;

      // --- CHORES ---
      case 'cleaning':
        return loc.choreCleaning;
      case 'shopping':
        return loc.choreShopping;
      case 'laundry':
        return loc.choreLaundry;
      case 'cooking':
        return loc.choreCooking;
      case 'ironing':
        return loc.choreIroning;
      case 'dishes':
        return loc.choreDishes;
      case 'repair':
        return loc.choreRepair;
      case 'plants':
        return loc.chorePlants;

      // --- SELF CARE ---
      case 'manicure':
        return loc.careManicure;
      case 'skincare':
        return loc.careSkincare;
      case 'hair':
        return loc.careHair;
      case 'massage':
        return loc.careMassage;
      case 'facemask':
        return loc.careFaceMask;
      case 'bath':
        return loc.careBath;
      case 'digital_detox':
        return loc.careDetox;

      default:
        return "";
    }
  }

  static String getJournalSentence(BuildContext context, String id) {
    final loc = AppLocalizations.of(context)!;
    switch (id) {
      // HEALTH
      case 'sport':
        return loc.journal_sport;
      case 'healthy_food':
        return loc.journal_healthy_food;
      case 'fast_food':
        return loc.journal_fast_food;
      case 'water':
        return loc.journal_water;
      case 'walking':
        return loc.journal_walking;
      case 'vitamins':
        return loc.journal_vitamins;
      case 'sleep_health':
        return loc.journal_sleep_health;
      case 'doctor':
        return loc.journal_doctor;
      case 'drink_water':
        return loc.journal_drink_water;
      case 'no_sugar':
        return loc.journal_no_sugar;
      case '10k_steps':
        return loc.journal_10k_steps;

      // SOCIAL
      case 'friends':
        return loc.journal_friends;
      case 'family':
        return loc.journal_family;
      case 'party':
        return loc.journal_party;
      case 'partner':
        return loc.journal_partner;
      case 'guests':
        return loc.journal_guests;
      case 'colleagues':
        return loc.journal_colleagues;
      case 'travel':
        return loc.journal_travel;
      case 'volunteer':
        return loc.journal_volunteer;

      // HOBBIES
      case 'gaming':
        return loc.journal_gaming;
      case 'reading':
        return loc.journal_reading;
      case 'movie':
        return loc.journal_movie;
      case 'art':
        return loc.journal_art;
      case 'music':
        return loc.journal_music;
      case 'coding':
        return loc.journal_coding;
      case 'photography':
        return loc.journal_photography;
      case 'crafts':
        return loc.journal_crafts;
      case 'read_book':
        return loc.journal_read_book;
      case 'journaling':
        return loc.journal_journaling;
      case 'meditation':
        return loc.journal_meditation;
      case 'early_rise':
        return loc.journal_early_rise;

      // CHORES
      case 'cleaning':
        return loc.journal_cleaning;
      case 'shopping':
        return loc.journal_shopping;
      case 'laundry':
        return loc.journal_laundry;
      case 'cooking':
        return loc.journal_cooking;
      case 'ironing':
        return loc.journal_ironing;
      case 'dishes':
        return loc.journal_dishes;
      case 'repair':
        return loc.journal_repair;
      case 'plants':
        return loc.journal_plants;
      case 'no_smoking':
        return loc.journal_no_smoking;

      // SELF CARE
      case 'manicure':
        return loc.journal_manicure;
      case 'skincare':
        return loc.journal_skincare;
      case 'hair':
        return loc.journal_hair;
      case 'massage':
        return loc.journal_massage;
      case 'facemask':
        return loc.journal_facemask;
      case 'bath':
        return loc.journal_bath;
      case 'digital_detox':
        return loc.journal_digital_detox;
      case 'social_media_detox':
        return loc.journal_social_media_detox;

      default:
        return "";
    }
  }

  static String getMoodSentence(BuildContext context, String moodCode) {
    final loc = AppLocalizations.of(context)!;
    switch (moodCode) {
      case 'happy':
        return loc.mood_sentence_nese;
      case 'sad':
        return loc.mood_sentence_huzun;
      case 'romantic':
        return loc.mood_sentence_romantik;
      case 'angry':
        return loc.mood_sentence_sinirli;
      case 'tired':
        return loc.mood_sentence_yorgun;
      case 'hopeful':
        return loc.mood_sentence_umut;
      case 'peaceful':
        return loc.mood_sentence_huzur;
      case 'nostalgic':
        return loc.mood_sentence_nostaljik;
      case 'mystic':
        return loc.mood_sentence_huzur;
      default:
        return loc.introNeutral("");
    }
  }

  static String getSleepSentence(BuildContext context, String sleep) {
    final loc = AppLocalizations.of(context)!;
    if (sleep == 'good') return loc.sleep_good;
    if (sleep == 'bad') return loc.sleep_bad;
    return '';
  }

  static String getWeatherSentence(BuildContext context, String weatherId) {
    final loc = AppLocalizations.of(context)!;
    switch (weatherId) {
      case 'sunny':
        return loc.weather_sentence_sunny;
      case 'cloudy':
        return loc.weather_sentence_cloudy;
      case 'rainy':
        return loc.weather_sentence_rainy;
      case 'snowy':
        return loc.weatherSentenceSnowy;
      case 'windy':
        return loc.weatherSentenceWindy;
      case 'foggy':
        return loc.weatherSentenceFoggy;
      case 'hail':
        return loc.weatherSentenceHail;
      default:
        return "";
    }
  }

  static String getMoodName(BuildContext context, String moodCode) {
    final loc = AppLocalizations.of(context)!;
    switch (moodCode) {
      case 'happy':
        return loc.moodHappy;
      case 'sad':
        return loc.moodSad;
      case 'romantic':
        return loc.moodRomantic;
      case 'angry':
        return loc.moodAngry;
      case 'tired':
        return loc.moodTired;
      case 'hopeful':
        return loc.moodHopeful;
      case 'peaceful':
        return loc.moodPeaceful;
      case 'nostalgic':
        return loc.moodNostalgic;
      case 'mystic':
        return loc.moodMystic;
      default:
        return loc.moodUnknown;
    }
  }

  static String getMoodDescription(BuildContext context, String moodCode) {
    final loc = AppLocalizations.of(context)!;
    switch (moodCode) {
      case 'happy':
        return loc.descHappy;
      case 'sad':
        return loc.descSad;
      case 'romantic':
        return loc.descRomantic;
      case 'angry':
        return loc.descAngry;
      case 'tired':
        return loc.descTired;
      case 'hopeful':
        return loc.descHopeful;
      case 'peaceful':
        return loc.descPeaceful;
      case 'nostalgic':
        return loc.descNostalgic;
      case 'mystic':
        return loc
            .descAll; // Use generic or add specific if needed, defaulting to generic-ish
      default:
        return loc.descAll;
    }
  }
}
