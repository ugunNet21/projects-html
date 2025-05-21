<?php 

/*1. Users & Authentication*/

Schema::create('users', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->string('email')->unique();
    $table->timestamp('email_verified_at')->nullable();
    $table->string('password');
    $table->rememberToken();
    $table->timestamps();
    $table->softDeletes();
});

Schema::create('password_reset_tokens', function (Blueprint $table) {
    $table->string('email')->primary();
    $table->string('token');
    $table->timestamp('created_at')->nullable();
});

Schema::create('sessions', function (Blueprint $table) {
    $table->string('id')->primary();
    $table->foreignUuid('user_id')->nullable()->index();
    $table->string('ip_address', 45)->nullable();
    $table->text('user_agent')->nullable();
    $table->longText('payload');
    $table->integer('last_activity')->index();
});

/* 2. Spatie Permission Tables*/
Schema::create('roles', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name')->unique();
    $table->string('guard_name')->default('web');
    $table->timestamps();
});

Schema::create('permissions', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name')->unique();
    $table->string('guard_name')->default('web');
    $table->timestamps();
});

Schema::create('model_has_permissions', function (Blueprint $table) {
    $table->uuid('permission_id');
    $table->string('model_type');
    $table->uuid('model_id');
    
    $table->foreign('permission_id')->references('id')->on('permissions')->onDelete('cascade');
    $table->primary(['permission_id', 'model_id', 'model_type']);
});

Schema::create('model_has_roles', function (Blueprint $table) {
    $table->uuid('role_id');
    $table->string('model_type');
    $table->uuid('model_id');
    
    $table->foreign('role_id')->references('id')->on('roles')->onDelete('cascade');
    $table->primary(['role_id', 'model_id', 'model_type']);
});

Schema::create('role_has_permissions', function (Blueprint $table) {
    $table->uuid('permission_id');
    $table->uuid('role_id');
    
    $table->foreign('permission_id')->references('id')->on('permissions')->onDelete('cascade');
    $table->foreign('role_id')->references('id')->on('roles')->onDelete('cascade');
    $table->primary(['permission_id', 'role_id']);
});

/* 3. Staff & Personnel */

Schema::create('staff', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('user_id')->constrained()->cascadeOnDelete();
    $table->string('nip')->unique()->nullable();
    $table->string('position');
    $table->string('specialization')->nullable();
    $table->string('phone')->nullable();
    $table->date('join_date');
    $table->boolean('is_active')->default(true);
    $table->timestamps();
    $table->softDeletes();
});

Schema::create('staff_schedules', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('staff_id')->constrained('staff')->cascadeOnDelete();
    $table->enum('day', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']);
    $table->time('start_time');
    $table->time('end_time');
    $table->timestamps();
});

/* 4. Patients */

Schema::create('patients', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('nik')->unique();
    $table->string('name');
    $table->string('birth_place');
    $table->date('birth_date');
    $table->enum('gender', ['male', 'female']);
    $table->text('address');
    $table->string('phone')->nullable();
    $table->string('bpjs_number')->nullable();
    $table->string('blood_type')->nullable();
    $table->text('allergy')->nullable();
    $table->timestamps();
    $table->softDeletes();
});

/* 5. Registration & Queue */
Schema::create('services', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->string('code')->unique();
    $table->text('description')->nullable();
    $table->boolean('is_active')->default(true);
    $table->timestamps();
});

Schema::create('registrations', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('patient_id')->constrained()->cascadeOnDelete();
    $table->foreignUuid('service_id')->constrained()->cascadeOnDelete();
    $table->string('registration_number')->unique();
    $table->date('registration_date');
    $table->enum('status', ['waiting', 'in_progress', 'completed', 'canceled'])->default('waiting');
    $table->text('complaint');
    $table->integer('queue_number');
    $table->boolean('is_bpjs')->default(false);
    $table->string('bpjs_number')->nullable();
    $table->timestamps();
});

Schema::create('vital_signs', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('registration_id')->constrained()->cascadeOnDelete();
    $table->decimal('height')->nullable();
    $table->decimal('weight')->nullable();
    $table->integer('blood_pressure_systolic')->nullable();
    $table->integer('blood_pressure_diastolic')->nullable();
    $table->decimal('temperature')->nullable();
    $table->integer('pulse')->nullable();
    $table->integer('respiration')->nullable();
    $table->timestamps();
});

/* 6. Medical Records */

Schema::create('medical_records', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('registration_id')->constrained()->cascadeOnDelete();
    $table->foreignUuid('staff_id')->constrained('staff')->cascadeOnDelete();
    $table->text('diagnosis');
    $table->text('treatment');
    $table->text('notes')->nullable();
    $table->timestamps();
});

Schema::create('prescriptions', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('medical_record_id')->constrained()->cascadeOnDelete();
    $table->text('instructions')->nullable();
    $table->timestamps();
});

Schema::create('medicines', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->string('code')->unique();
    $table->string('category');
    $table->string('unit');
    $table->decimal('price', 10, 2);
    $table->integer('stock');
    $table->integer('min_stock');
    $table->timestamps();
});

Schema::create('prescription_items', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('prescription_id')->constrained()->cascadeOnDelete();
    $table->foreignUuid('medicine_id')->constrained()->cascadeOnDelete();
    $table->integer('quantity');
    $table->text('dosage');
    $table->timestamps();
});

/* 7. Laboratory */
Schema::create('lab_tests', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->text('description')->nullable();
    $table->decimal('price', 10, 2);
    $table->timestamps();
});

Schema::create('lab_orders', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('medical_record_id')->constrained()->cascadeOnDelete();
    $table->text('notes')->nullable();
    $table->enum('status', ['pending', 'in_progress', 'completed'])->default('pending');
    $table->timestamps();
});

Schema::create('lab_order_items', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('lab_order_id')->constrained()->cascadeOnDelete();
    $table->foreignUuid('lab_test_id')->constrained()->cascadeOnDelete();
    $table->text('result')->nullable();
    $table->text('normal_range')->nullable();
    $table->timestamps();
});

/* 8. Maternal & Child Health */

Schema::create('pregnant_women', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('patient_id')->constrained()->cascadeOnDelete();
    $table->integer('gravida');
    $table->integer('para');
    $table->integer('abortus');
    $table->date('hpht');
    $table->date('estimated_due_date');
    $table->integer('height');
    $table->integer('lila')->nullable();
    $table->timestamps();
});

Schema::create('prenatal_visits', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('pregnant_woman_id')->constrained('pregnant_women')->cascadeOnDelete();
    $table->date('visit_date');
    $table->integer('gestational_age');
    $table->integer('weight');
    $table->integer('blood_pressure_systolic');
    $table->integer('blood_pressure_diastolic');
    $table->integer('fundal_height');
    $table->string('fetal_position')->nullable();
    $table->integer('fetal_heart_rate')->nullable();
    $table->text('complaint')->nullable();
    $table->text('treatment')->nullable();
    $table->text('notes')->nullable();
    $table->timestamps();
});

Schema::create('immunizations', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->text('description')->nullable();
    $table->timestamps();
});

Schema::create('immunization_schedules', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('patient_id')->constrained()->cascadeOnDelete();
    $table->foreignUuid('immunization_id')->constrained()->cascadeOnDelete();
    $table->date('schedule_date');
    $table->date('given_date')->nullable();
    $table->foreignUuid('staff_id')->nullable()->constrained('staff')->cascadeOnDelete();
    $table->text('notes')->nullable();
    $table->timestamps();
});


/* 9. Inventory */
Schema::create('inventory_categories', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->text('description')->nullable();
    $table->timestamps();
});

Schema::create('inventory_items', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('category_id')->constrained('inventory_categories')->cascadeOnDelete();
    $table->string('name');
    $table->string('code')->unique();
    $table->string('unit');
    $table->integer('stock');
    $table->integer('min_stock');
    $table->decimal('price', 10, 2);
    $table->timestamps();
});

Schema::create('inventory_transactions', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('item_id')->constrained('inventory_items')->cascadeOnDelete();
    $table->enum('type', ['in', 'out']);
    $table->integer('quantity');
    $table->text('description')->nullable();
    $table->foreignUuid('staff_id')->constrained('staff')->cascadeOnDelete();
    $table->timestamps();
});

/* 10. Financial */
Schema::create('payment_types', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->string('name');
    $table->boolean('is_bpjs')->default(false);
    $table->timestamps();
});

Schema::create('payments', function (Blueprint $table) {
    $table->uuid('id')->primary();
    $table->foreignUuid('registration_id')->constrained()->cascadeOnDelete();
    $table->foreignUuid('payment_type_id')->constrained()->cascadeOnDelete();
    $table->decimal('amount', 10, 2);
    $table->text('notes')->nullable();
    $table->foreignUuid('staff_id')->constrained('staff')->cascadeOnDelete();
    $table->timestamps();
});

