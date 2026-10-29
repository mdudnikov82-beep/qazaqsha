package com.maxim.qazaqsha

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/** Home-screen widget: word of the day, streak and today's tasks. The app
 *  writes the values (lib/core/home_widget_sync.dart); this only shows them. */
class QazaqshaWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.qazaqsha_widget).apply {
                setTextViewText(R.id.widget_streak, widgetData.getString("streak", "Қазақша"))
                setTextViewText(R.id.widget_word, widgetData.getString("word_kk", "Сәлем!"))
                setTextViewText(R.id.widget_translation, widgetData.getString("word_ru", "Слово дня"))
                setTextViewText(R.id.widget_tasks, widgetData.getString("tasks", "Откройте Qazaqsha"))
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
