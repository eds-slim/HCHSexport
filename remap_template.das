// Export and pseudonymise HCHS DICOM data
// Copyright (C) 2019, Eckhard Schlemm, CSI, UKE
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Dicom-Meta-Information-Header not included. 
// MediaStorageSOPInstanceUID taken care of by gdcmanon



// (0008,0005) // SpecificCharacterSet
// (0008,0008) // ImageType
// (0008,0012) // InstanceCreationDate
-(0008,0013) // InstanceCreationTime
// (0008,0016) // SOPClassUID: 1.2.840.10008.5.1.4.1.1.4 ~ MR Image Storage
// (0008,0018) // SOPInstanceUID: replaced by gdcmanon
// (0008,0020) // StudyDate
// (0008,0021) // SeriesDate
// (0008,0022) // AcquisitionDate
// (0008,0023) // ContentDate
-(0008,0030) // StudyTime
-(0008,0031) // SeriesTime
-(0008,0032) // AcquisitionTime
-(0008,0033) // ContentTime
-(0008,0050) // AccessionNumber
// (0008,0060) // Modality
// (0008,0070) // Manufacturer
-(0008,0080) // InstitutionName
-(0008,0081) // InstitutionAddress
-(0008,0090) // ReferringPhysicianName
-(0008,1010) // StationName
-(0008,1030) // StudyDescription
-(0008,1032) // ProcedureCodeSequence
(0008,103e) := "{SeriesDescription}" // SeriesDescription: removed by gdcmanon, reinserted
-(0008,1040) // InstitutionalDepartmentName
-(0008,1048) // PhysiciansOfRecord
-(0008,1050) // PerformingPhysicianName
-(0008,1070) // OperatorsName
// (0008,1090) // ManufacturersModelName
-(0008,1110) // ReferencedStudySequence
-(0008,1111) // ReferencedProcedureStepSequence


-(0009,0000) // PrivateGroupLength
-(0009,0010) // PrivateCreator
// (0009,1012) // Unknown Tag & Data


-(0010,0010) // PatientName
(0010,0020) := "{PatientID}" // PatientID
-(0010,0021) // IssuerOfPatientID
(0010,0030) := "{PatientBirthDate}" // PatientBirthDate: removed by gdcmanon, reinserted in form 19XX0101
-(0010,0040) // PatientSex
-(0010,1010) // PatientAge
-(0010,1020) // PatientSize
-(0010,1030) // PatientWeight
-(0010,1040) // PatientAddress
-(0010,21c0) // PregnancyStatus


// (0018,0015) // BodyPartExamined
// (0018,0020) // ScanningSequence
// (0018,0021) // SequenceVariant
// (0018,0022) // ScanOptions
// (0018,0023) // MRAcquisitionType
// (0018,0024) // SequenceName
// (0018,0025) // AngioFlag
// (0018,0050) // SliceThickness
// (0018,0080) // RepetitionTime
// (0018,0081) // EchoTime
// (0018,0083) // NumberOfAverages
// (0018,0084) // ImagingFrequency
// (0018,0085) // ImagedNucleus
// (0018,0086) // EchoNumber
// (0018,0087) // MagneticFieldStrength
// (0018,0089) // NumberOfPhaseEncodingSteps
// (0018,0091) // EchoTrainLength
// (0018,0093) // PercentSampling
// (0018,0094) // PercentPhaseFieldOfView
// (0018,0095) // PixelBandwidth
-(0018,1000) // DeviceSerialNumber
// (0018,1020) // SoftwareVersion
(0018,1030) := "{ProtocolName}" // ProtocolName: removed by gdcmanon, reinserted
// (0018,1251) // TransmitCoilName
// (0018,1310) // AcquisitionMatrix
// (0018,1312) // InPlanePhaseEncodingDirection
// (0018,1314) // FlipAngle
// (0018,1315) // VariableFlipAngleFlag
// (0018,1316) // SAR
// (0018,1318) // DB-Dt
// (0018,5100) // PatientPosition


-(0019,0010) // Unknown Tag & Data
-(0019,1008) // Unknown Tag & Data
-(0019,1009) // Unknown Tag & Data
-(0019,100b) // Unknown Tag & Data
-(0019,100a) // Unknown Tag & Data
-(0019,100f) // Unknown Tag & Data
-(0019,1011) // Unknown Tag & Data
-(0019,1012) // Unknown Tag & Data
-(0019,1013) // Unknown Tag & Data
-(0019,1014) // Unknown Tag & Data
-(0019,1015) // Unknown Tag & Data
-(0019,1016) // Unknown Tag & Data
-(0019,1017) // Unknown Tag & Data
-(0019,1018) // Unknown Tag & Data
-(0019,1025) // Unknown Tag & Data
-(0019,1026) // Unknown Tag & Data
-(0019,1028) // Unknown Tag & Data
-(0019,1029) // Unknown Tag & Data


// (0020,000d) // StudyInstanceUID:  replaced by gdcmanon
// (0020,000e) // SeriesInstanceUID:  replaced by gdcmanon
(0020,0010) := 1 // StudyID: removed by gdcmanon
// (0020,0011) // SeriesNumber
// (0020,0012) // AcquisitionNumber
// (0020,0013) // InstanceNumber
// (0020,0032) // ImagePositionPatient
// (0020,0037) // ImageOrientationPatient
// (0020,0052) // FrameOfReferenceUID:  replaced by gdcmanon
// (0020,1040) // PositionReferenceIndicator
// (0020,1041) // SliceLocation


// (0028,0002) // SamplesPerPixel
// (0028,0004) // PhotometricInterpretation
// (0028,0010) // Rows
// (0028,0011) // Columns
// (0028,0030) // PixelSpacing
// (0028,0100) // BitsAllocated
// (0028,0101) // BitsStored
// (0028,0102) // HighBit
// (0028,0103) // PixelRepresentation
// (0028,0106) // SmallestImagePixelValue
// (0028,0107) // LargestImagePixelValue
// (0028,1050) // WindowCenter
// (0028,1051) // WindowWidth
// (0028,1055) // WindowCenterAndWidthExplanation


-(0029,0010) // PrivateCreator
-(0029,0011) // PrivateCreator
-(0029,1008) // CSAImageHeaderType
-(0029,1009) // CSAImageHeaderVersion
-(0029,1010) // CSAImageHeaderInfo
-(0029,1018) // CSASeriesHeaderType
-(0029,1019) // CSASeriesHeaderVersion
-(0029,1020) // CSASeriesHeaderInfo
-(0029,1160) // SeriesWorkflowStatus


-(0032,1032) // RequestingPhysician
// (0032,1033) // RequestingService
// (0032,1060) // RequestedProcedureDescription
-(0032,1064) // RequestedProcedureCodeSequence


-(0040,0244) // PerformedProcedureStepStartDate
-(0040,0245) // PerformedProcedureStepStartTime
-(0040,0253) // PerformedProcedureStepID
-(0040,0254) // PerformedProcedureStepDescription
-(0040,0275) // RequestAttributesSequence
-(0040,0280) // CommentsOnPerformedProcedureStep
-(0040,2017) // FillerOrderNum-ImagingServiceReq


-(0051,0010) // PrivateCreator
-(0051,1008) // Unknown Tag & Data
-(0051,1009) // Unknown Tag & Data
-(0051,100a) // Unknown Tag & Data
-(0051,100b) // Unknown Tag & Data
-(0051,100c) // Unknown Tag & Data
-(0051,100d) // Unknown Tag & Data
-(0051,100e) // Unknown Tag & Data
-(0051,100f) // Unknown Tag & Data
-(0051,1011) // Unknown Tag & Data
-(0051,1012) // Unknown Tag & Data
-(0051,1013) // Unknown Tag & Data
-(0051,1015) // Unknown Tag & Data
-(0051,1016) // Unknown Tag & Data
-(0051,1017) // Unknown Tag & Data
-(0051,1019) // Unknown Tag & Data


-(0903,0010) // PrivateCreator
-(0903,1010) // Unknown Tag & Data
-(0903,1011) // Unknown Tag & Data
-(0903,1012) // Unknown Tag & Data
-(0905,0010) // PrivateCreator
-(0905,1030) // Unknown Tag & Data
-(7fd1,0000) // PrivateGroupLength
-(7fd1,0010) // PrivateCreator
-(7fd1,1010) // Unknown Tag & Data
// (7fe0,0010) // PixelData
