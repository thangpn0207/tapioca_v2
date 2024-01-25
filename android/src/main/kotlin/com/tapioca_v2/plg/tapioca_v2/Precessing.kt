package com.tapioca_v2.plg.tapioca_v2

import android.graphics.Bitmap

data class Filter(val map: Map<String, Any>) {
    val type: String    by map
    val alpha: Double by map
}

data class ImageOverlay(val map: Map<String, Any>) {
    val bitmap: ByteArray    by map
    val x: Int by map
    val y: Int by map
}

data class TextOverlay(val map: Map<String, Any>) {
    val text: String    by map
    val x: Int by map
    val y: Int by map
    val size: Int by map
    val color: String by map
    val start: Int? by map
    val duration: Int? by map

}
