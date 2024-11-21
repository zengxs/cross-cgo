package main

type User struct {
	ID   int    `gorm:"primaryKey,autoIncrement"`
	Name string `gorm:"not null"`
}
