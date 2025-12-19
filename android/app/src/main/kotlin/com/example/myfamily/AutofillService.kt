package com.example.myfamily

import android.app.assist.AssistStructure
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.service.autofill.AutofillService
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.view.autofill.AutofillId
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import android.util.Log

/**
 * AutofillService implementation for MyFamily app
 * Provides autofill functionality for family member information
 */
@RequiresApi(Build.VERSION_CODES.O)
class MyFamilyAutofillService : AutofillService() {

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: android.os.CancellationSignal,
        callback: FillCallback
    ) {
        // Get the structure from the request
        val structure = request.fillContexts.lastOrNull()?.structure ?: run {
            callback.onFailure("No structure in request")
            return
        }

        // Parse the structure to find fillable fields
        val parser = StructureParser(structure)
        parser.parse()

        // Get data from Flutter app via method channel
        // For now, we'll use a simple approach with SharedPreferences or direct database access
        // In production, you'd use MethodChannel to communicate with Flutter
        
        val fillResponse = buildFillResponse(parser, this)
        
        if (fillResponse != null) {
            callback.onSuccess(fillResponse)
        } else {
            callback.onFailure("Could not build fill response")
        }
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        // Handle save requests if needed
        // This allows saving new data from forms
        callback.onSuccess()
    }

    private fun buildFillResponse(
        parser: StructureParser,
        context: Context
    ): FillResponse? {
        val fillResponseBuilder = FillResponse.Builder()

        // Get family member data from database
        // Note: In a real implementation, you'd use MethodChannel to get data from Flutter
        val memberData = getFamilyMemberData(context)

        if (memberData.isEmpty()) {
            return null
        }

        // For each detected field, create a suggestion
        parser.fields.forEach { field ->
            val autofillId = field.autofillId
            val hints = field.hints

            // Find matching data based on hints
            val matchingValue = findMatchingValue(hints, memberData)

            if (matchingValue != null && autofillId != null) {
                val remoteViews = RemoteViews(packageName, android.R.layout.simple_list_item_1)
                remoteViews.setTextViewText(android.R.id.text1, matchingValue)
                
                val dataset = android.service.autofill.Dataset.Builder(remoteViews).apply {
                    setValue(autofillId, AutofillValue.forText(matchingValue))
                }.build()

                fillResponseBuilder.addDataset(dataset)
            }
        }

        return fillResponseBuilder.build()
    }

    private fun getFamilyMemberData(context: Context): Map<String, String> {
        // Get database path - Flutter stores it in app_flutter directory
        // Try multiple possible paths
        val possiblePaths = listOf(
            context.filesDir.absolutePath + "/app_flutter/myfamily.db",
            context.filesDir.absolutePath + "/myfamily.db",
            context.getDir("app_flutter", Context.MODE_PRIVATE).absolutePath + "/myfamily.db"
        )
        
        var dbPath: String? = null
        for (path in possiblePaths) {
            val dbFile = java.io.File(path)
            if (dbFile.exists()) {
                dbPath = path
                break
            }
        }
        
        if (dbPath == null) {
            Log.d("MyFamilyAutofill", "Database not found in any expected location")
            return emptyMap()
        }

        val data = mutableMapOf<String, String>()
        
        try {
            // Open SQLite database
            val db = android.database.sqlite.SQLiteDatabase.openDatabase(
                dbPath,
                null,
                android.database.sqlite.SQLiteDatabase.OPEN_READONLY
            )

            // Query family members table
            val cursor = db.query(
                "family_members",
                arrayOf("first_name", "last_name", "email", "phone", "address", "city", "state", "zip_code"),
                null,
                null,
                null,
                null,
                "updated_at DESC",
                "1" // Get most recently updated member
            )

            if (cursor.moveToFirst()) {
                val firstNameIndex = cursor.getColumnIndex("first_name")
                val lastNameIndex = cursor.getColumnIndex("last_name")
                val emailIndex = cursor.getColumnIndex("email")
                val phoneIndex = cursor.getColumnIndex("phone")
                val addressIndex = cursor.getColumnIndex("address")
                val cityIndex = cursor.getColumnIndex("city")
                val stateIndex = cursor.getColumnIndex("state")
                val zipCodeIndex = cursor.getColumnIndex("zip_code")

                if (firstNameIndex >= 0) {
                    val firstName = cursor.getString(firstNameIndex) ?: ""
                    val lastName = if (lastNameIndex >= 0) cursor.getString(lastNameIndex) ?: "" else ""
                    data["firstName"] = firstName
                    data["lastName"] = lastName
                    data["name"] = "$firstName $lastName".trim()
                }

                if (emailIndex >= 0) {
                    val email = cursor.getString(emailIndex)
                    if (!email.isNullOrEmpty()) {
                        data["email"] = email
                    }
                }

                if (phoneIndex >= 0) {
                    val phone = cursor.getString(phoneIndex)
                    if (!phone.isNullOrEmpty()) {
                        data["phone"] = phone
                    }
                }

                if (addressIndex >= 0) {
                    val address = cursor.getString(addressIndex)
                    if (!address.isNullOrEmpty()) {
                        data["address"] = address
                    }
                }

                if (cityIndex >= 0) {
                    val city = cursor.getString(cityIndex)
                    if (!city.isNullOrEmpty()) {
                        data["city"] = city
                    }
                }

                if (stateIndex >= 0) {
                    val state = cursor.getString(stateIndex)
                    if (!state.isNullOrEmpty()) {
                        data["state"] = state
                    }
                }

                if (zipCodeIndex >= 0) {
                    val zipCode = cursor.getString(zipCodeIndex)
                    if (!zipCode.isNullOrEmpty()) {
                        data["zipCode"] = zipCode
                    }
                }
            }

            cursor.close()
            db.close()
        } catch (e: Exception) {
            android.util.Log.e("MyFamilyAutofill", "Error reading database: ${e.message}")
        }

        return data
    }

    private fun findMatchingValue(
        hints: List<String>,
        data: Map<String, String>
    ): String? {
        // Map autofill hints to our data fields
        val hintMapping = mapOf(
            "emailAddress" to "email",
            "phone" to "phone",
            "personName" to "name",
            "postalAddress" to "address",
            "postalCode" to "zipCode",
            "personName" to "firstName",
            "personName" to "lastName",
        )

        for (hint in hints) {
            val fieldName = hintMapping[hint]
            if (fieldName != null && data.containsKey(fieldName)) {
                return data[fieldName]
            }
        }

        return null
    }
}

/**
 * Parser for AssistStructure to extract fillable fields
 */
class StructureParser(private val structure: AssistStructure) {
    val fields = mutableListOf<Field>()

    fun parse() {
        val windowNodes = structure.windowNodeCount
        for (i in 0 until windowNodes) {
            val windowNode = structure.getWindowNodeAt(i)
            val rootViewNode = windowNode.rootViewNode
            parseViewNode(rootViewNode)
        }
    }

    private fun parseViewNode(viewNode: AssistStructure.ViewNode) {
        val autofillHints = viewNode.autofillHints
        val autofillId = viewNode.autofillId
        val autofillType = viewNode.autofillType

        if (autofillHints != null && autofillHints.isNotEmpty() && autofillId != null) {
            fields.add(Field(autofillId, autofillHints.toList(), autofillType))
        }

        val childrenCount = viewNode.childCount
        for (i in 0 until childrenCount) {
            parseViewNode(viewNode.getChildAt(i))
        }
    }
}

data class Field(
    val autofillId: AutofillId,
    val hints: List<String>,
    val autofillType: Int
)

