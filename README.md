### Event and Seating Organization System

## Overview

This project involves the development of a set of logical predicates in Prolog designed to solve a variety of real-world problems, including event scheduling, room occupancy analysis, and seating arrangement optimization. The tasks are divided into several parts, each addressing specific requirements provided by different departments, such as the Secretariat, the Academic Area, and the Building Management Team.

The primary objectives are to:
1. Identify problematic events with no assigned rooms.
2. Organize events efficiently based on certain conditions.
3. Calculate the percentage of room occupancy and determine critical occupancy levels.
4. Solve a complex seating arrangement problem for a family dinner with specific seating preferences.

## 1. Data Quality

The first task requires identifying events that lack assigned rooms, specifically:
- Events without any rooms assigned.
- Events without rooms, filtered by a given day of the week.
- Events without rooms, filtered by a given time period.

To address this, three predicates are implemented:
- `eventosSemSalas/1`: Identifies events without any room assigned.
- `eventosSemSalasDiaSemana/2`: Filters events without rooms by a specific day of the week.
- `eventosSemSalasPeriodo/2`: Filters events without rooms by a specific time period.

## 2. Simple Searches

The Academic Area requested assistance with the implementation of a set of predicates for organizing events. The following predicate is developed to accomplish this task:
- `organizaEventos/3`: Organizes events into a schedule based on specific criteria, ensuring proper order and coordination of events, using recursion without relying on higher-order predicates.

## 3. Critical Room Occupancy

The Building Management Team requires assistance with calculating room occupancy percentages, particularly for room types that experience high levels of occupancy. Critical occupancy thresholds are defined, and events are analyzed to identify when a room is considered critically occupied.

The following predicate is implemented:
- `ocupaSlot/5`: Determines if a given time slot overlaps with an event's scheduled time, helping to assess room usage and detect potential conflicts.

## 4. Seating Arrangement for Family Dinner

A final challenge involves organizing a family dinner seating arrangement based on a set of specific preferences for seating positions. The table is rectangular, with eight places (two at the heads and three on each side). The seating arrangement must adhere to specific requirements:
- The host and their partner sit at the two heads of the table, with the host at the head closest to the fireplace.
- The elderly family member must sit to the right of the partner.
- Specific family members should be seated next to or near one another.
- Two young family members should not sit directly across from each other.

The solution involves a program that verifies all seating conditions and generates an optimal arrangement that satisfies all requirements.

