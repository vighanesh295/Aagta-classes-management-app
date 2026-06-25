-- Supabase Database Schema for Aagte Classes

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- USERS Table
CREATE TABLE users (
  uid UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'student',
  "photoUrl" TEXT,
  phone TEXT,
  "fcmToken" TEXT,
  "isActive" BOOLEAN DEFAULT true,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- STUDENTS Table
CREATE TABLE students (
  uid UUID REFERENCES users(uid) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  "studentId" TEXT NOT NULL,
  phone TEXT,
  "photoUrl" TEXT,
  "batchId" TEXT,
  "batchName" TEXT,
  course TEXT,
  address TEXT,
  "parentName" TEXT,
  "parentPhone" TEXT,
  education TEXT,
  "attendancePercent" NUMERIC DEFAULT 0,
  achievements TEXT[] DEFAULT '{}',
  "isActive" BOOLEAN DEFAULT true,
  "enrolledAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- TEACHERS Table
CREATE TABLE teachers (
  uid UUID REFERENCES users(uid) PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  "photoUrl" TEXT,
  qualification TEXT,
  subjects TEXT[] DEFAULT '{}',
  batches TEXT[] DEFAULT '{}',
  "isActive" BOOLEAN DEFAULT true,
  "joinedAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- FEES Table
CREATE TABLE fees (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "studentId" UUID REFERENCES students(uid),
  "studentName" TEXT NOT NULL,
  "totalFees" NUMERIC DEFAULT 0,
  "paidAmount" NUMERIC DEFAULT 0,
  "academicYear" TIMESTAMP WITH TIME ZONE,
  "batchId" TEXT,
  course TEXT,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  "updatedAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- INSTALLMENTS Table
CREATE TABLE installments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "feeId" UUID REFERENCES fees(id),
  "studentId" UUID REFERENCES students(uid),
  "installmentNo" INTEGER DEFAULT 1,
  amount NUMERIC DEFAULT 0,
  "dueDate" TIMESTAMP WITH TIME ZONE NOT NULL,
  "paidDate" TIMESTAMP WITH TIME ZONE,
  status TEXT DEFAULT 'pending',
  notes TEXT
);

-- LECTURES Table
CREATE TABLE lectures (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  "teacherId" UUID REFERENCES teachers(uid),
  "batchId" TEXT,
  "startTime" TIMESTAMP WITH TIME ZONE NOT NULL,
  "endTime" TIMESTAMP WITH TIME ZONE NOT NULL,
  "zoomLink" TEXT,
  "materialUrl" TEXT,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- STUDY MATERIALS Table
CREATE TABLE study_materials (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT,
  url TEXT NOT NULL,
  "uploadedBy" UUID REFERENCES users(uid),
  "batchId" TEXT,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- ANNOUNCEMENTS Table
CREATE TABLE announcements (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  audience TEXT DEFAULT 'all',
  "createdBy" UUID REFERENCES users(uid),
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- ATTENDANCE Table
CREATE TABLE attendance (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "studentId" UUID REFERENCES students(uid),
  "lectureId" UUID REFERENCES lectures(id),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'present'
);

-- NOTIFICATIONS Table
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "userId" UUID REFERENCES users(uid),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  "isRead" BOOLEAN DEFAULT false,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- RESULTS Table
CREATE TABLE results (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  "studentId" UUID REFERENCES students(uid),
  "examName" TEXT NOT NULL,
  marks NUMERIC NOT NULL,
  "totalMarks" NUMERIC NOT NULL,
  "date" TIMESTAMP WITH TIME ZONE NOT NULL,
  "createdAt" TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- Setup Storage Bucket
insert into storage.buckets (id, name, public) values ('profile_images', 'profile_images', true) ON CONFLICT DO NOTHING;

-- Disable RLS for rapid development (Turn on in production!)
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE students DISABLE ROW LEVEL SECURITY;
ALTER TABLE teachers DISABLE ROW LEVEL SECURITY;
ALTER TABLE fees DISABLE ROW LEVEL SECURITY;
ALTER TABLE installments DISABLE ROW LEVEL SECURITY;
ALTER TABLE lectures DISABLE ROW LEVEL SECURITY;
ALTER TABLE study_materials DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE attendance DISABLE ROW LEVEL SECURITY;
ALTER TABLE notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE results DISABLE ROW LEVEL SECURITY;
