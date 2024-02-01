package com.tapioca_v2.plg.tapioca_v2.filter

import android.graphics.BitmapFactory
import android.graphics.Canvas
import com.daasuu.mp4compose.filter.GlOverlayFilter
import com.tapioca_v2.plg.tapioca_v2.WatermarkOverlay


class GlWatermarkFilter(watermarkOverlay:  WatermarkOverlay) : GlOverlayFilter() {
    private val watermarkOverlay: WatermarkOverlay = watermarkOverlay

    override fun drawCanvas(canvas : Canvas) {
        val bmp = BitmapFactory.decodeByteArray(watermarkOverlay.byteArray, 0,
            watermarkOverlay.byteArray.size)
        if (bmp != null && !bmp.isRecycled) {
            when (watermarkOverlay.position) {
                Position.LEFT_TOP.ordinal -> canvas.drawBitmap(bmp,0F,0F,
                    null)
                Position.LEFT_BOTTOM.ordinal -> canvas.drawBitmap(
                    bmp,
                    0F,
                    (canvas.height - bmp.height).toFloat(),
                    null
                )

                Position.RIGHT_TOP.ordinal -> canvas.drawBitmap(
                    bmp,
                   ( canvas.width - bmp.width).toFloat(),
                    0F,
                    null
                )

                Position.RIGHT_BOTTOM.ordinal -> canvas.drawBitmap(
                    bmp,
                    (canvas.width - bmp.width).toFloat(),
                    (canvas.height - bmp.height).toFloat(),
                    null
                )
            }
        }
    }

}
enum class Position {
    LEFT_TOP,
    LEFT_BOTTOM,
    RIGHT_TOP,
    RIGHT_BOTTOM
}